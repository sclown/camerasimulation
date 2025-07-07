import AVFoundation

public class VideoRecorder {
    private var assetWriter: AVAssetWriter
    private var assetWriterInput: AVAssetWriterInput
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor
    private var startTime: CFTimeInterval
    
    public init(_ videoOutputURL: URL, size: CGSize) throws {
        try? FileManager.default.removeItem(at: videoOutputURL)
        assetWriter = try AVAssetWriter(outputURL: videoOutputURL, fileType: .mp4)
        
        let width = max(Int(size.width), 1)
        let height = max(Int(size.height), 1)
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ]
        
        assetWriterInput = AVAssetWriterInput(
            mediaType: .video,
            outputSettings: videoSettings
        )
        assetWriterInput.expectsMediaDataInRealTime = true
        
        let sourcePixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height
        ]
        
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: assetWriterInput,
            sourcePixelBufferAttributes: sourcePixelBufferAttributes
        )
        
        if assetWriter.canAdd(assetWriterInput) {
            assetWriter.add(assetWriterInput)
        }
        
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: .zero)
        
        startTime = CACurrentMediaTime()
    }
    
    public func add(_ image: CGImage, at time: CMTime) {
        _ = image.pixelBuffer.map {
            pixelBufferAdaptor.append($0, withPresentationTime: time)
        }
    }
    
    @discardableResult
    public func stop() async -> URL {
        assetWriterInput.markAsFinished()
        await assetWriter.finishWriting()
        return assetWriter.outputURL
    }
    
    public static func defaultURL() -> URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        )[0]
        let videoOutputURL = URL(fileURLWithPath: documentsPath)
            .appendingPathComponent("output_\(Date().timeIntervalSince1970).mp4")
        
        return videoOutputURL
    }
}

extension CGImage {
    var pixelBuffer: CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            nil,
            &pixelBuffer
        )
        
        guard let unwrappedPixelBuffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(unwrappedPixelBuffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedPixelBuffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            return nil
        }
        
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(self, in: frame)
        CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, [])
        
        return unwrappedPixelBuffer
    }
}

