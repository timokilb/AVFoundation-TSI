//
//  PreviewView.swift
//  AVFoundation TSI
//
//  Created by Timo Kilb  on 09.06.21.
//

import Foundation
import AVFoundation
import UIKit

class CameraPreviewView: UIView {
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
