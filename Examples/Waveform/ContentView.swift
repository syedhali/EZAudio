//
//  ContentView.swift
//  Waveform
//
//  Created by Haris Ali on 9/8/25.
//

import EZAudio
import EZAudioSwiftUI
import SwiftUI

class ContentViewModel: NSObject, ObservableObject {
    private let microphone: EZMicrophone
    
    // Thread-safe
    private(set) var audioDataCopy: [Float] = []
    
    // Used for UI binding
    @Published var audioData: [Float] = []
    
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

extension Array where Element: Numeric {
    mutating func ensureCapacity(_ capacity: Int) {
        guard count < capacity else { return }
        self = .init(repeating: self.first ?? 0, count: capacity)
    }
}

extension ContentViewModel: EZMicrophoneDelegate {
    func microphone(
        _ microphone: EZMicrophone!,
        hasAudioReceived buffer: UnsafePointer<UnsafePointer<Float>>,
        withBufferSize bufferSize: UInt32,
        withNumberOfChannels numberOfChannels: UInt32) {
            guard numberOfChannels > 0 else { return }
            let frames = Int(bufferSize)
            audioDataCopy.ensureCapacity(frames)
            audioDataCopy.withUnsafeMutableBufferPointer {
                guard let ptr = $0.baseAddress else { return }
                ptr.update(from: buffer[0], count: frames)
            }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.audioData = self.audioDataCopy
            }
    }
}

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            Button("Start", action: viewModel.start)
            Button("Stop", action: viewModel.stop)
            
            EZAudioPlotView(
                audioData: viewModel.audioData
            )
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
