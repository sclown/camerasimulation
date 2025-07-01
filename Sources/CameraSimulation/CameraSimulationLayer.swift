//
//  CameraSimulationLayer.swift
//

import AVFoundation
import ImageGenerator
import UIKit

public class CameraSimulationLayer: CALayer {
    private let text: String
    private let colors: [UIColor]

    private var recorder: VideoRecorder? = nil
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var captureTime: CFTimeInterval = 0

    private var timeText = ""

    public init(text: String) {
        self.text = text
        self.colors = .palette(text: text)
        super.init()
        
        start()
    }
    
    override init(layer: Any) {
        if let layer = layer as? CameraSimulationLayer {
            self.text = layer.text
            self.colors = layer.colors
        } else {
            self.text = ""
            self.colors = []
        }
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(in ctx: CGContext) {
        UIGraphicsPushContext(ctx)
        drawInternal(in: ctx)
        UIGraphicsPopContext()
    }
    
    func drawInternal(in ctx: CGContext) {
        ctx.drawImage(
            text + timeText,
            colors: colors,
            size: frame.size
        )
    }
    
    public var snapshot: UIImage {
        UIGraphicsImageRenderer(size: frame.size).image {
            draw(in: $0.cgContext)
        }
    }
    
    public func start() {
        startTime = CACurrentMediaTime()
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    public func startRecording(to url: URL) {
        captureTime = CACurrentMediaTime()
        recorder = try? VideoRecorder(url, size: bounds.size)
        capture(0)
    }
    
    public func stopRecording() async -> URL? {
        await recorder?.stop()
    }
    
    @objc private func update() {
        let currentTime = CACurrentMediaTime() - startTime
        timeText = "\n\((currentTime * 10).rounded() / 10)"
        capture(CACurrentMediaTime() - captureTime)
        setNeedsDisplay()
    }
    
    func capture(_ offset: CFTimeInterval) {
        guard let recorder else { return }
        let presentationTime = CMTime(seconds: offset, preferredTimescale: 600)
        
        autoreleasepool {
            snapshot.cgImage.map {
                recorder.add($0, at: presentationTime)
            }
        }
    }
}
