//
//  CameraView.swift
//  Mail
//
//  Created by Nathan Lee on 3/1/2024.
//

import SwiftUI
import AVKit

struct CameraView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            // Handle captured video frames
            // You can process or display the frames as needed
        }
    }

    var didCapturePhoto: ((UIImage) -> Void)?

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraView>) -> UIViewController {
        let viewController = UIViewController()

        DispatchQueue.global(qos: .userInitiated).async {
            let captureSession = AVCaptureSession()

            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                return
            }

            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                
                let device = input.device
                configureCaptureDevice(device)
                
                // Set the session preset to low quality
                if captureSession.canSetSessionPreset(AVCaptureSession.Preset.low) {
                    captureSession.sessionPreset = AVCaptureSession.Preset.low
                }
                
                // Change frame rate
                do {
                    try device.lockForConfiguration()
                    device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 15)  // Adjust the timescale for the desired frame rate
                    device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 30)
                    device.unlockForConfiguration()
                } catch {
                    // Handle configuration error
                }

                let output = AVCaptureVideoDataOutput()
                output.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))

                if (captureSession.canAddOutput(output)) {
                    captureSession.addOutput(output)
                }

                captureSession.startRunning()

                DispatchQueue.main.async {
                    // Create and add the previewLayer on the main thread
                    let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer.frame = viewController.view.layer.bounds
                    previewLayer.videoGravity = .resizeAspectFill

                    viewController.view.layer.addSublayer(previewLayer)
                }
            }
        }

        return viewController
    }

    func configureCaptureDevice(_ device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            
            // Disable autofocus
            if device.isFocusModeSupported(.locked) {
                device.focusMode = .locked
            }
            
            // Disable autoexposure
            if device.isExposureModeSupported(.locked) {
                device.exposureMode = .locked
            }
            
            device.unlockForConfiguration()
        } catch {
            // Handle configuration error
        }
    }


    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CameraView>) {
        // Update UI if needed
    }
}
