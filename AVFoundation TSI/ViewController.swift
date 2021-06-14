//
//  ViewController.swift
//  AVFoundation TSI
//
//  Created by Timo Kilb  on 09.06.21.
//

import UIKit

class ViewController: UIViewController {
    
    var isRecording: Bool = false

    var cameraSession: CameraSession?
    
    lazy var previewView: CameraPreviewView = {
        let view = CameraPreviewView()
        return view
    }()
    
    lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.layer.cornerRadius = 40
        button.setTitle("Rec", for: .normal)
        button.addTarget(self, action: #selector(handleCameraButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("View Controller did load!")
        self.view.backgroundColor = .black
        self.cameraSession = CameraSession()
        self.cameraSession?.startSession()
        self.previewView.videoPreviewLayer.session = self.cameraSession?.session
        self.setupViews()
    }

    private func setupViews() {
        self.view.addSubview(self.cameraButton)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        cameraButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        cameraButton.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        cameraButton.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
        
        self.view.addSubview(self.previewView)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        previewView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        previewView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        previewView.heightAnchor.constraint(equalTo: previewView.widthAnchor, constant: 640.0/480.0).isActive = true

    }
    
    @objc private func handleCameraButtonTapped() {
        if self.isRecording {
            self.cameraButton.setTitle("Rec", for: .normal)
            self.isRecording = false
            self.cameraSession?.videoWriter?.stopWriting()
        } else {
            self.cameraButton.setTitle("Stop", for: .normal)
            self.isRecording = true
            self.cameraSession?.videoWriter?.startWriting()
        }
    }
    

}

