//
//  CameraService.swift
//

import AVFoundation
import UIKit

final class CameraService: NSObject {
    let session = AVCaptureSession()
    private let previewLayer: AVCaptureVideoPreviewLayer
    private let videoOutput = AVCaptureMovieFileOutput()
    private let photoOutput = AVCapturePhotoOutput()
    private var videoContinuation: CheckedContinuation<URL, Error>?
    private var photoContinuation: CheckedContinuation<UIImage, Error>?
    
    var layer: CALayer { previewLayer }
    
    override init() {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init()

        session.sessionPreset = .high
        session.setup(with: videoOutput, photoOutput)

        previewLayer.videoGravity = .resizeAspectFill
        start()
    }
        
    func start() {
        if !session.isRunning {
            Task.detached { [session] in
                session.startRunning()
            }
        }
    }
    
    func stop() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func capturePhoto() async -> UIImage? {
        guard session.isRunning else { return nil }
        async let photoResult = withCheckedThrowingContinuation {
            photoContinuation = $0
        }
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
        return try? await photoResult
    }

    func startRecording(to url: URL) {
        guard session.isRunning else { return }
        videoOutput.startRecording(to: url, recordingDelegate: self)
    }
    
    func stopRecording() async -> URL? {
        async let videoResult = withCheckedThrowingContinuation {
            videoContinuation = $0
        }
        videoOutput.stopRecording()
        return try? await videoResult
    }
}

extension CameraService: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        Task { @MainActor in
            if let error = error {
                print("Error recording video: \(error)")
                videoContinuation?.resume(throwing: error)
                videoContinuation = nil
                return
            }
            videoContinuation?.resume(returning: outputFileURL)
            videoContinuation = nil
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        Task { @MainActor in
            if let error {
                photoContinuation?.resume(throwing: error)
                photoContinuation = nil
                return
            }
            guard let image = photo.cgImageRepresentation()
            else {
                photoContinuation?.resume(throwing: BrokenPhoto(photo: photo))
                return
            }
            photoContinuation?.resume(
                returning: UIImage(cgImage: image)
            )
            photoContinuation = nil
        }
    }
}

struct BrokenPhoto: Error {
    let photo: AVCapturePhoto
}

extension AVCaptureSession {
    func clear() {
        if isRunning {
            stopRunning()
        }
        
        for input in inputs {
            removeInput(input)
        }
        
        for output in outputs {
            removeOutput(output)
        }
    }
    
    func setup(with video: AVCaptureMovieFileOutput, _ photo: AVCapturePhotoOutput) {
        beginConfiguration()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              canAddInput(input),
              canAddOutput(video),
              canAddOutput(photo) else {
            commitConfiguration()
            return
        }
        
        addInput(input)
        addOutput(video)
        addOutput(photo)
        commitConfiguration()
    }
}
