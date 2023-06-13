// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX

/// These filters are Butterworth second-order IIR filters. They offer an almost flat
/// passband and very good precision and stopband attenuation.
///
public class HighPassButterworthFilter: Node {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var auAudioUnit: AUAudioUnit = registerAndInstantiateAU(componentDescription: .init(effect: "bthp"))

    // MARK: - Parameters

    /// Specification details for cutoffFrequency
    public static let cutoffFrequencyDef = NodeParameterDef(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency",
        address: akGetParameterAddress("HighPassButterworthFilterParameterCutoffFrequency"),
        defaultValue: 500.0,
        range: 12.0 ... 20000.0,
        unit: .hertz
    )

    /// Cutoff frequency. (in Hertz)
    @Parameter(cutoffFrequencyDef) public var cutoffFrequency: AUValue

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff frequency. (in Hertz)
    ///
    public init(
        _ input: Node,
        cutoffFrequency: AUValue = cutoffFrequencyDef.defaultValue
    ) {
        self.input = input

        setupParameters()

        self.cutoffFrequency = cutoffFrequency
    }
}
