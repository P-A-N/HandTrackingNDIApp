//
//  Camera.swift
//  Example
//
//  Created by Tomoya Hirano on 2020/04/02.
//  Copyright © 2020 Tomoya Hirano. All rights reserved.
//

import AVFoundation

class Camera: NSObject {
    lazy var session: AVCaptureSession = .init()
    lazy var input: AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: device)
    lazy var device: AVCaptureDevice = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back)!
    lazy var output: AVCaptureVideoDataOutput = .init()
    
    override init() {
        super.init()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        session.sessionPreset = .hd1920x1080
        session.addInput(input)
        session.addOutput(output)
        session.connections[0].videoOrientation = .landscapeLeft
        session.connections[0].isVideoMirrored = false
    }
    
    func setSampleBufferDelegate(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        output.setSampleBufferDelegate(delegate, queue: .main)
    }
    
    func start() {
        session.startRunning()
        updateToggle(toggle: true)
    }
    
    func stop() {
        session.stopRunning()
    }
    
    func updateToggle(toggle value:Bool)
    {
        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if value {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
}
