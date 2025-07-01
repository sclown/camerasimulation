import AVKit
import CameraSimulation
import SwiftUI

struct VideoCameraView: View {
#if targetEnvironment(simulator)
    private let service = CameraSimulationService()
#else
    private let service = CameraService()
#endif
    @State private var recordedVideoURL: URL?
    @State private var image: UIImage?
    @State private var capturing = false
    @State private var recording = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if let videoURL = recordedVideoURL {
                VStack {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(height: UIScreen.main.bounds.height * 0.6)
                                            
                    Button("Record Another Video") {
                        recordedVideoURL = nil
                        service.start()
                    }
                    .padding()
                }
            } else if let image {
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.height * 0.6)
                                            
                    Button("Make another photo") {
                        self.image = nil
                        service.start()
                    }
                    .padding()
                }
            } else {
                ZStack {
                    CameraPreviewView(layer: service.layer)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        HStack(spacing: 20) {
                            capturePhoto
                            captureVideo
                        }
                        
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var captureVideo: some View {
        Button(action: {
            if recording {
                recording = false
                Task {
                    recordedVideoURL = await service.stopRecording()
                }
            } else {
                recording = true
                service.startRecording(to: VideoRecorder.defaultURL())
            }
        }) {
            Image(systemName: recording ? "stop.circle.fill" : "video.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(recording ? .red : .white)
                .background(Circle().fill(Color.black.opacity(0.5)).frame(width: 88, height: 88))
                .padding(.bottom, 30)
        }
    }
    
    @ViewBuilder
    var capturePhoto: some View {
        Button {
            guard capturing == false else { return }
            Task {
                capturing = true
                image = await service.capturePhoto()
                capturing = false
            }
        } label: {
            Image(systemName: capturing ? "stop.circle.fill" : "camera.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(capturing ? .red : .white)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 88, height: 88)
                )
                .padding(.bottom, 30)
        }
    }
}
