// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AudioKit
import AudioKitEX
import AVFoundation
import CSoundpipeAudioKit

/// This filter reiterates input with an echo density determined by loopDuration.
/// The attenuation rate is independent and is determined by reverbDuration, the
/// reverberation duration (defined as the time in seconds for a signal to decay to 1/1000,
/// or 60dB down from its original amplitude). Output from a comb filter will appear
/// only after loopDuration seconds.
///
public class CombFilterReverb: Node {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var auAudioUnit: AUAudioUnit = registerAndInstantiateAU(componentDescription: .init(effect: "comb"))

    // MARK: - Parameters

    /// Specification details for reverbDuration
    public static let reverbDurationDef = NodeParameterDef(
        identifier: "reverbDuration",
        name: "Reverb duration",
        address: akGetParameterAddress("CombFilterReverbParameterReverbDuration"),
        defaultValue: 1.0,
        range: 0.0 ... 10.0,
        unit: .seconds
    )

    /// The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude. (aka RT-60).
    @Parameter(reverbDurationDef) public var reverbDuration: AUValue

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - reverbDuration: The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude. (aka RT-60).
    ///   - loopDuration: The loop time of the filter, in seconds. This can also be thought of as the delay time. Determines frequency response curve, loopDuration * sr/2 peaks spaced evenly between 0 and sr/2.
    ///
    public init(
        _ input: Node,
        reverbDuration: AUValue = reverbDurationDef.defaultValue,
        loopDuration: AUValue = 0.1
    ) {
        self.input = input

        setupParameters()

        akCombFilterReverbSetLoopDuration(akau.dsp, loopDuration)

        self.reverbDuration = reverbDuration
    }
}
