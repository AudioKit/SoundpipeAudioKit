// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX

/// 8 delay line stereo FDN reverb, with feedback matrix based upon physical
/// modeling scattering junction of 8 lossless waveguides of equal characteristic impedance.
///
public class CostelloReverb: Node {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var auAudioUnit: AUAudioUnit = registerAndInstantiateAU(componentDescription: .init(effect: "rvsc"))

    // MARK: - Parameters

    /// Specification details for feedback
    public static let feedbackDef = NodeParameterDef(
        identifier: "feedback",
        name: "Feedback",
        address: akGetParameterAddress("CostelloReverbParameterFeedback"),
        defaultValue: 0.6,
        range: 0.0 ... 1.0,
        unit: .percent
    )

    /// Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable.
    @Parameter(feedbackDef) public var feedback: AUValue

    /// Specification details for cutoffFrequency
    public static let cutoffFrequencyDef = NodeParameterDef(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency",
        address: akGetParameterAddress("CostelloReverbParameterCutoffFrequency"),
        defaultValue: 4000.0,
        range: 12.0 ... 20000.0,
        unit: .hertz
    )

    /// Low-pass cutoff frequency.
    @Parameter(cutoffFrequencyDef) public var cutoffFrequency: AUValue

    /// Dry/wet mix.
    public static let balanceDef = NodeParameterDef(
        identifier: "balance",
        name: "Balance",
        address: akGetParameterAddress("CostelloReverbParameterBalance"),
        defaultValue: 1,
        range: 0 ... 1,
        unit: .percent
    )

    /// Dry/wet mix. Should be a value between 0-1.
    @Parameter(balanceDef) public var balance: AUValue

    // MARK: - Initialization

    /// Initialize this reverb node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - balance: dry wet mix
    ///   - feedback: Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable.
    ///   - cutoffFrequency: Low-pass cutoff frequency.
    ///
    public init(
        _ input: Node,
        balance: AUValue = balanceDef.defaultValue,
        feedback: AUValue = feedbackDef.defaultValue,
        cutoffFrequency: AUValue = cutoffFrequencyDef.defaultValue
    ) {
        self.input = input

        setupParameters()

        self.balance = balance
        self.feedback = feedback
        self.cutoffFrequency = cutoffFrequency
    }
}
