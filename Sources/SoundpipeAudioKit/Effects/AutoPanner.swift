// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX

/// Table-lookup panning with linear interpolation
public class AutoPanner: Node {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var auAudioUnit: AUAudioUnit = registerAndInstantiateAU(componentDescription: .init(effect: "apan"))

    // MARK: - Parameters

    /// Specification details for frequency
    public static let frequencyDef = NodeParameterDef(
        identifier: "frequency",
        name: "Frequency",
        address: akGetParameterAddress("AutoPannerParameterFrequency"),
        defaultValue: 10.0,
        range: 0.0 ... 100.0,
        unit: .hertz
    )

    /// Frequency (Hz)
    @Parameter(frequencyDef) public var frequency: AUValue

    /// Specification details for depth
    public static let depthDef = NodeParameterDef(
        identifier: "depth",
        name: "Depth",
        address: akGetParameterAddress("AutoPannerParameterDepth"),
        defaultValue: 1.0,
        range: 0.0 ... 1.0,
        unit: .generic
    )

    /// Depth
    @Parameter(depthDef) public var depth: AUValue

    // MARK: - Initialization

    /// Initialize this auto panner node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency: Frequency (Hz)
    ///   - depth: Depth
    ///   - waveform: Shape of the curve
    ///
    public init(
        _ input: Node,
        frequency: AUValue = frequencyDef.defaultValue,
        depth: AUValue = depthDef.defaultValue,
        waveform: Table = Table(.positiveSine)
    ) {
        self.input = input

        setupParameters()

        akau.setWavetable(waveform.content)

        self.frequency = frequency
        self.depth = depth
    }
}
