//
//  EZAudioPlotView.swift
//  EZAudio
//
//  Created by Haris Ali on 9/8/25.
//

import EZAudioUI
import SwiftUI

public struct EZAudioPlotView: PlatformViewRepresentable {
    public var audioData: [Float]
    public var color: Color
    public var shouldFill: Bool
    public var shouldMirror: Bool
    public var shouldCenterYAxis: Bool
    public var plotType: EZPlotType
    public var shouldOptimizeForRealtimePlot: Bool

    public init(
        audioData: [Float],
        color: Color = .blue,
        shouldFill: Bool = false,
        shouldMirror: Bool = false,
        shouldCenterYAxis: Bool = false,
        plotType: EZPlotType = .buffer,
        shouldOptimizeForRealtimePlot: Bool = true
    ) {
        self.audioData = audioData
        self.color = color
        self.shouldFill = shouldFill
        self.shouldMirror = shouldMirror
        self.shouldCenterYAxis = shouldCenterYAxis
        self.plotType = plotType
        self.shouldOptimizeForRealtimePlot = shouldOptimizeForRealtimePlot
    }

    fileprivate func makeView() -> EZAudioPlot {
        let view = EZAudioPlot()
        updateView(view)
        return view
    }

    fileprivate func updateView(_ view: EZAudioPlot) {
//        view.color = PlatformColor(color)
        view.shouldFill = shouldFill
        view.shouldMirror = shouldMirror
        view.shouldCenterYAxis = shouldCenterYAxis
        view.plotType = plotType
        view.shouldOptimizeForRealtimePlot = shouldOptimizeForRealtimePlot
        let count = UInt32(audioData.count)
        view.updateBuffer(audioData, withBufferSize: count)
        view.redraw()
    }
}

#if os(macOS)
    public extension EZAudioPlotView {
        func makeNSView(context _: Context) -> EZAudioPlot {
            makeView()
        }

        func updateNSView(_ view: EZAudioPlot, context _: Context) {
            updateView(view)
        }
    }
#else
    public extension EZAudioPlotView {
        func makeUIView(context _: Context) -> EZAudioPlot {
            makeView()
        }

        func updateUIView(_ view: EZAudioPlot, context _: Context) {
            updateView(view)
        }
    }
#endif

private struct EZAudioPlotPreview: View {
    // Controls (Double for SwiftUI Slider)
    @State private var type: WaveformGenerator.Kind = .sine
    @State private var frequency: Double = 3.0
    @State private var amplitude: Double = 0.75
    @State private var sampleCount: Int = 1024

    // Plot options
    @State private var shouldFill = false
    @State private var shouldMirror = false
    @State private var shouldCenterYAxis = true
    @State private var plotType: EZPlotType = .buffer
    @State private var shouldOptimizeForRealtimePlot = true

    // Recompute samples (convert Double → Float)
    private var samples: [Float] {
        WaveformGenerator.generateWaveform(
            type,
            frequency: Float(frequency),
            amplitude: Float(amplitude),
            sampleCount: sampleCount
        )
    }

    var body: some View {
        VStack(spacing: 12) {
            // Plot
            EZAudioPlotView(
                audioData: samples,
                shouldFill: shouldFill,
                shouldMirror: shouldMirror,
                shouldCenterYAxis: shouldCenterYAxis,
                plotType: plotType,
                shouldOptimizeForRealtimePlot: shouldOptimizeForRealtimePlot
            )
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            // avoid macOS 12 ShapeStyle API; use Color explicitly
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3)))

            // Controls (no GroupBox initializer that requires macOS 12)
            VStack(alignment: .leading, spacing: 8) {
                Text("Waveform").font(.headline)
                HStack {
                    Picker("Type", selection: $type) {
                        ForEach(WaveformGenerator.Kind.allCases) { w in
                            Text(w.rawValue.capitalized).tag(w)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Stepper(
                        "Samples: \(sampleCount)",
                        value: $sampleCount,
                        in: 64 ... 4096,
                        step: 64
                    )
                }

                HStack {
                    LabeledSlider(
                        title: "Frequency",
                        value: $frequency,
                        range: 0.25 ... 16,
                        step: 0.25
                    )
                    LabeledSlider(
                        title: "Amplitude",
                        value: $amplitude,
                        range: 0 ... 1,
                        step: 0.05
                    )
                }
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.08)))

            VStack(alignment: .leading, spacing: 8) {
                Text("Plot Options").font(.headline)
                HStack {
                    Toggle("Fill", isOn: $shouldFill)
                    Toggle("Mirror", isOn: $shouldMirror)
                    Toggle("Center Y", isOn: $shouldCenterYAxis)
                }
                HStack {
                    Picker("Plot Type", selection: $plotType) {
                        Text("Rolling").tag(EZPlotType.rolling)
                        Text("Buffer").tag(EZPlotType.buffer)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Toggle(
                        "Optimize Realtime",
                        isOn: $shouldOptimizeForRealtimePlot
                    )
                }
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.08)))
        }
        .padding(.horizontal)
        .padding(.vertical, 40)
    }
}

// Slider helper that uses Double (works on macOS 10.15+)
private struct LabeledSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: "%.2f", value))
            }
            Slider(value: $value, in: range, step: step)
        }
        .frame(maxWidth: 360)
    }
}

#Preview {
    EZAudioPlotPreview()
}
