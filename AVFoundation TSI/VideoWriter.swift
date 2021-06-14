//
//  VideoWriter.swift
//  AVFoundation TSI
//
//  Created by Timo Kilb  on 09.06.21.
//

import Foundation
import AVFoundation

protocol VideoWriterDelegate: AnyObject {
    func didWriteMovieAt(url outputURL: URL)
}

class VideoWriter: NSObject {
    
    var dispatchQueue: DispatchQueue
    
    weak var delegate: VideoWriterDelegate?
    
    var isWriting: Bool = false
    var firstSample: Bool = false// Somehting like synching?
    var assetWriter: AVAssetWriter!
    var assetWriterVideoInput: AVAssetWriterInput!
    var assetWriterAudioInput: AVAssetWriterInput!
    
    var videoSettings: [String : Any]?
    var audioSettings: [String : Any]?
    
    init(videoSettings: [String : Any]?, audioSettings: [String : Any]?) {
        self.dispatchQueue = DispatchQueue(label: "writingQueue", qos: .background)
        self.videoSettings = videoSettings
        self.audioSettings = audioSettings
        super.init()
    }
    
    
    // MARK: - Start and Stop
    
    
    /// Makes a new AVAssetWriter object and sets it up with the recommended Settings for mp4
    /// Then sets isWriting to true so that the first processed video CMSampleBuffer starst the session -> @see func processSampleBuffer
    func startWriting() {
        self.dispatchQueue.async {
            let fileType = AVFileType.mp4
            let url = self.outputURL()
            do {
                try self.assetWriter = AVAssetWriter(outputURL: url, fileType: fileType)
//                print("video settings: \(self.videoSettings)")
//                print("audio settings: \(self.audioSettings)")
                /// Video input
                self.assetWriterVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: self.videoSettings)
                self.assetWriterVideoInput.expectsMediaDataInRealTime = true
                if self.assetWriter.canAdd(self.assetWriterVideoInput) {
                    self.assetWriter.add(self.assetWriterVideoInput)
                } else {
                    print("Could not add video assetWriterinput")
                }
                
                /// Audio input
                self.assetWriterAudioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: self.audioSettings)
                self.assetWriterAudioInput.expectsMediaDataInRealTime = true
                if self.assetWriter.canAdd(self.assetWriterAudioInput) {
                    self.assetWriter.add(self.assetWriterAudioInput)
                } else {
                    print("Could not add audio assetWriterinput")
                }
                self.isWriting = true
                self.firstSample = true
                print("did set first sample to true :)")
            } catch let error as NSError {
                print("Could not instantiate assetWriter: \(error.localizedDescription)")
            }
        }
    }
    
    func stopWriting() {
        self.isWriting = false
        self.dispatchQueue.async {
            self.assetWriter.finishWriting {
                if self.assetWriter.status == .completed {
                    DispatchQueue.main.async { // Mabye run on another queue
                        /// Tell someone that writing has been finished to a URL
                        self.delegate?.didWriteMovieAt(url: self.assetWriter.outputURL)
                    }
                } else {
                    print("Failed to Write a Video")
                }
            }
        }
    }
    
    

    
    // MARK: - Processing function
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        if !self.isWriting {
            return
        }
        print("A sampleBuffer is Writing!")

        let formatDescription = sampleBuffer.formatDescription
        let mediaType = formatDescription?.mediaType
        
        /// Handle Video sampleBuffer
        if mediaType == .video {
            let timestamp = sampleBuffer.presentationTimeStamp
            
            /// Set the sourceTime if the sample is the first one
            if self.firstSample {
                if self.assetWriter.startWriting() {
                    print("Yo started assetWriter: \(self.assetWriter.status)") 
                    self.assetWriter.startSession(atSourceTime: timestamp)
                    self.firstSample = false
                }
            }
            
            /// Append the buffer if the writerInput is ready for it
            if self.assetWriterVideoInput.isReadyForMoreMediaData {
                if !self.assetWriterVideoInput.append(sampleBuffer) {
                    print("Could not append video sampleBuffer")
                }
            }
        }
        
        /// Handle AudioSampleBuffer
        else if !self.firstSample && mediaType == .audio {
            /// Append the buffer if the writerInput is ready for it
            if assetWriterAudioInput.isReadyForMoreMediaData {
                if !self.assetWriterAudioInput.append(sampleBuffer) {
                    print("Could not append audio sampleBuffer")
                }
            }
        }
        
    }
    
    
    /// Returns a url that the video will be written to
    private func outputURL() -> URL {
        let filePath = NSTemporaryDirectory().appending("movie.mp4")
        let url = URL(fileURLWithPath: filePath)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch let error as NSError {
                print("Error removing item at url: \(error.localizedDescription)")
            }
        }
        return url
    }
    
}
