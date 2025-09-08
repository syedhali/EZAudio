//
//  ContentView.swift
//  Waveform
//
//  Created by Haris Ali on 9/8/25.
//

import EZAudio
import SwiftUI

class ContentViewModel: NSObject, ObservableObject {
    private let microphone: EZMicrophone
    
    override init() {
        microphone = EZMicrophone()
        super.init()
        microphone.delegate = self
    }
    
    func start() {
        microphone.startFetchingAudio()
    }
    
    func stop() {
        microphone.stopFetchingAudio()
    }
    
}

extension ContentViewModel: EZMicrophoneDelegate {
    func microphone(
        _ microphone: EZMicrophone!,
        hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!,
        withBufferSize bufferSize: UInt32,
        withNumberOfChannels numberOfChannels: UInt32) {
        
    }
}

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            Button("Start", action: viewModel.start)
            Button("Stop", action: viewModel.stop)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
