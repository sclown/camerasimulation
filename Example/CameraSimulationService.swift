//
//  CameraSimulationService.swift
//

import CameraSimulation
import UIKit

final class CameraSimulationService {
    private let simulationLayer = CameraSimulationLayer(text: "camera-emulation")
    var layer: CALayer { simulationLayer }
    
    func start() {
        simulationLayer.start()
    }
    
    func stop() {
        simulationLayer.stop()
    }
    
    func capturePhoto() async -> UIImage? {
        stop()
        return simulationLayer.snapshot
    }
    
    func startRecording(to url: URL) {
        simulationLayer.startRecording(to: url)
    }
    
    func stopRecording() async -> URL? {
        await simulationLayer.stopRecording()
    }
}
