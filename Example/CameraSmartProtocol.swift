//
//  CameraSmartProtocol.swift
//

import UIKit

protocol CameraSmartProtocol {
    var layer: CALayer { get }
    func start()
    func stop()
    func capturePhoto() async -> UIImage?
    
    func startRecording(to url: URL)
    func stopRecording() async -> URL?

}

extension CameraSimulationService: CameraSmartProtocol {}
extension CameraService: CameraSmartProtocol {}
