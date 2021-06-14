//
//  CameraSession.swift
//  AVFoundation TSI
//
//  Created by Timo Kilb  on 09.06.21.
//

import Foundation
import AVFoundation
import AssetsLibrary
import Photos

protocol CameraSessionDelegate: AnyObject {
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer)
    func startWriting()
    func stopWriting()
}

class CameraSession: NSObject {
    
    
    
    var session: AVCaptureSession?
    var videoWriter: VideoWriter?
    
    var activeVideoInput: AVCaptureDeviceInput?
    var activeAudioInput: AVCaptureDeviceInput?
    
    
    var videoDataOutput: AVCaptureVideoDataOutput?
    var audioDataOutput: AVCaptureAudioDataOutput?
    var cameraSessionQueue: DispatchQueue
    
    func setupSession() {
        self.session = AVCaptureSession()
        session?.sessionPreset = .vga640x480
    }
    
    func setupSessionInputs() {
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let audioDevice = AVCaptureDevice.default(for: .audio) else { return }
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            guard let session = self.session else { return }
            if session.canAddInput(videoInput) {
                self.session?.addInput(videoInput)
            } else {
                print("Could not add VideoInput")
            }
            
            if session.canAddInput(audioInput) {
                self.session?.addInput(audioInput)
            } else {
                print("Could not add AudioInput")
            }
            
        } catch let error as NSError {
            print("Could not setup device input: \(error.localizedDescription)")
        }
    }
    
    
    func setupSessionOutputs() {
        
        /// Creating video and audio data output
        self.videoDataOutput = AVCaptureVideoDataOutput()
        self.audioDataOutput = AVCaptureAudioDataOutput()
        
        guard let videoOutput = self.videoDataOutput, let audioOutput = self.audioDataOutput else { return }
        
        /// Video Settings
        let videoOutputSettings: [String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA
        ]
        // let alternativeVideoOutputSettings ...
        videoOutput.videoSettings = videoOutputSettings
        videoOutput.alwaysDiscardsLateVideoFrames = false
        videoOutput.setSampleBufferDelegate(self, queue: self.cameraSessionQueue)
        
        /// Audio Settings
        audioOutput.setSampleBufferDelegate(self, queue: self.cameraSessionQueue)
        
        
        // Now add the outputs to the session
        guard let sess = self.session else { return }
        if sess.canAddOutput(videoOutput) {
            print("Could add video output!")
            sess.addOutput(videoOutput)
        }
        
        if sess.canAddOutput(audioOutput) {
            print("Could add audioOutput")
            sess.addOutput(audioOutput)
        }

        let fileType = AVFileType.mp4
        let videoSettings = videoOutput.recommendedVideoSettingsForAssetWriter(writingTo: fileType)
        let audioSettings = audioOutput.recommendedAudioSettingsForAssetWriter(writingTo: fileType)
        //print("Those are the settings that were recommended: \(videoSettings), and \(audioSettings)")
        self.videoWriter = VideoWriter(videoSettings: videoSettings, audioSettings: audioSettings as! [String : Any]?)
        self.videoWriter?.delegate = self
        
        
    }
    
    func startSession() {
        cameraSessionQueue.async {
            guard let session = self.session else { return }
            if !session.isRunning {
                self.session?.startRunning()
            }
        }
    }
    
    func stopSession() {
        cameraSessionQueue.async {
            guard let session = self.session else { return }
            if session.isRunning {
                self.session?.stopRunning()
            }
        }
    }
    
    override init() {
        self.cameraSessionQueue = DispatchQueue(label: "cameraSession", qos: .background)
        super.init()
        self.setupSession()
        self.setupSessionInputs()
        self.setupSessionOutputs()

    }
    
}

/// Delegate methods to pass through the sampleBuffer

extension CameraSession: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("Did drop a sampleBuffer")
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.videoWriter?.processSampleBuffer(sampleBuffer)
    }
    
}

extension CameraSession: VideoWriterDelegate {
    func didWriteMovieAt(url outputURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
        }) { saved, error in
            if saved {
                print("Saved!")
            } else {
                print("Failed to save: \(error?.localizedDescription)")
            }
        }
    }
}
