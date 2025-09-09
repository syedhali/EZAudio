//
//  Utilities.swift
//  EZAudio
//
//  Created by Haris Ali on 9/8/25.
//

import SwiftUI

#if os(macOS)
    import AppKit

    typealias PlatformColor = NSColor
    typealias PlatformViewRepresentable = NSViewRepresentable
#else
    import UIKit

    typealias PlatformColor = UIColor
    typealias PlatformViewRepresentable = UIViewRepresentable
#endif

// MARK: - Waveform Generators

public enum WaveformGenerator {
    public enum Kind: String, CaseIterable, Identifiable {
        case sine
        case square
        case sawtooth
        case noise

        public var id: Self { self }
    }

    public static func generateWaveform(
        _ kind: Kind,
        frequency: Float = 1.0,
        amplitude: Float = 1.0,
        sampleCount: Int = 512
    ) -> [Float] {
        let twoPi = Float.pi * 2
        switch kind {
        case .sine:
            return (0 ..< sampleCount).map { i in
                let phase = (Float(i) / Float(sampleCount)) * twoPi * frequency
                return amplitude * sin(phase)
            }

        case .square:
            return (0 ..< sampleCount).map { i in
                let phase = (Float(i) / Float(sampleCount)) * twoPi * frequency
                return amplitude * (sin(phase) >= 0 ? 1.0 : -1.0)
            }

        case .sawtooth:
            return (0 ..< sampleCount).map { i in
                let phase = (Float(i) / Float(sampleCount)) * twoPi * frequency
                let frac = (phase / twoPi).truncatingRemainder(dividingBy: 1.0)
                return amplitude * (2.0 * frac - 1.0)
            }

        case .noise:
            var values: [Float] = []
            values.reserveCapacity(sampleCount)
            var last: Float = 0
            for _ in 0 ..< sampleCount {
                let target = Float.random(in: -1 ... 1) * amplitude
                last = (last * 0.9) + (target * 0.1)
                values.append(last)
            }
            return values
        }
    }
}
