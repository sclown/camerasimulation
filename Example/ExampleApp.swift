//
//  ExampleApp.swift
//  Example
//
//  Created by Dmitry Kurkin on 09.04.25.
//

import SwiftUI
import AVFoundation

@main
struct ExampleApp: App {
    @State private var permissions = false
    var body: some Scene {
        WindowGroup {
            Group {
                if permissions {
                    VideoCameraView()
                }
                else {
                    Text("No permisson for the camera")
                }
            }.onAppear {
                checkPermissions {
                    permissions = $0
                }
            }
        }
    }
}

@MainActor
func checkPermissions(completion: @escaping (Bool) -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
        completion(true)
    case .notDetermined:
        AVCaptureDevice.requestAccess(for: .video) { granted in
            Task{
                if granted {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    default: break
    }
}
