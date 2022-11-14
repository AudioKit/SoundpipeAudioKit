// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/SoundpipeAudioKit/

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX

/// Diode Ladder Filter is an new digital implementation of the VCS3 ladder filter
/// based on the work of Will Pirkle
/// "Virtual Analog (VA) Diode Ladder Filter"
///
public class DiodeLadderFilter: Node {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "diod")

    // MARK: - Parameters

    /// Specification for cutoffFrequency (still determining best ranges)
    public static let cutoffFrequencyDef = NodeParameterDef(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency",
        address: akGetParameterAddress("DiodeLadderFilterParameterCutoffFrequency"),
        defaultValue: 1000.0,
        range: 12.0 ... 20000.0,
        unit: .hertz
    )

    /// Filter cutoff frequency
    @Parameter(cutoffFrequencyDef) public var cutoffFrequency: AUValue

    /// Specification for resonance (still determining best ranges)
    public static let resonanceDef = NodeParameterDef(
        identifier: "resonance",
        name: "Resonance",
        address: akGetParameterAddress("DiodeLadderFilterParameterResonance"),
        defaultValue: 0.5,
        range: 0.0 ... 1.0,
        unit: .generic
    )

    /// Resonance
    @Parameter(resonanceDef) public var resonance: AUValue

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Filter cutoff frequency
    ///   - resonance: Resonance
    ///
    public init(
        _ input: Node,
        cutoffFrequency: AUValue = cutoffFrequencyDef.defaultValue,
        resonance: AUValue = resonanceDef.defaultValue
    ) {
        self.input = input

        setupParameters()

        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance
    }
}
