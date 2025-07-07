import SwiftUI

struct CameraPreviewView: UIViewRepresentable {
    let layer: CALayer
    
    func makeUIView(context: Context) -> PreviewView {
        PreviewView(layer)
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
    }
}

class PreviewView: UIView {
    private let childLayer: CALayer
    
    init(_ layer: CALayer) {
        childLayer = layer
        super.init(frame: .zero)
        
        backgroundColor = .black
        self.layer.addSublayer(childLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        childLayer.frame = bounds
    }
}

