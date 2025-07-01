//
//  PhotoCameraView.swift
//

import SwiftUI

struct PhotoCameraView: View {
    private let service = CameraSmartService(false)
    @State private var recording = false
    @State private var image: UIImage?
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if let image {
                result(image: image)
            } else {
                capture
            }
        }
    }
    
    @ViewBuilder
    func result(image: UIImage) -> some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: UIScreen.main.bounds.height * 0.5)
                                    
            Button("Make another photo") {
                self.image = nil
                service.start()
            }
            .padding()
        }
    }
    
    @ViewBuilder
    var capture: some View {
        ZStack {
            CameraPreviewView(layer: service.layer)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Button {
                    guard recording == false else { return }
                    Task {
                        recording = true
                        image = await service.capturePhoto()
                        recording = false
                    }
                } label: {
                    Image(systemName: recording ? "stop.circle.fill" : "camera.circle.fill")
                        .font(.system(size: 72))
                        .foregroundColor(recording ? .red : .white)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.5))
                                .frame(width: 88, height: 88)
                        )
                        .padding(.bottom, 30)
                }
            }
        }
    }
}
