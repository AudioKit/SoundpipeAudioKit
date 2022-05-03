// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import AudioKit
import AudioKitEX
import CAudioKitEX

/// Mix between two signals, usually used for a dry signal and wet signal
/// Allows for independent control of dry and wet signal
public class DryWetDualMixer: Node {

    let input1: Node
    let input2: Node

    /// Connected nodes
    public var connections: [Node] { [input1, input2] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(mixer: "dwmx")

    // MARK: - Parameters

    public static let dryDef = NodeParameterDef(
        identifier: "dry",
        name: "Dry Mix",
        address: akGetParameterAddress("DryWetMixerParameterDry"),
        defaultValue: 0.5,
        range: 0.0...1.0,
        unit: .generic
    )

    @Parameter(dryDef) public var dry: AUValue

    /// Specification details for wetds
    public static let wetDef = NodeParameterDef(
        identifier: "wet",
        name: "Wet Mix",
        address: akGetParameterAddress("DryWetMixerParameterWet"),
        defaultValue: 0.5,
        range: 0.0...1.0,
        unit: .generic
    )

    @Parameter(wetDef) public var wet: AUValue

    /// Initialize this dry wet mixer node
    ///
    /// - Parameters:
    ///   - input1: 1st source
    ///   - input2: 2nd source
    ///   - dryAmount: Amount of dry signal
    ///   - wetAmount: Amount of wet signal
    ///
    public init(_ input1: Node,
                _ input2: Node,
                dryAmount: AUValue = dryDef.defaultValue,
                wetAmount: AUValue = wetDef.defaultValue) {
        self.input1 = input1
        self.input2 = input2

        setupParameters()

        self.dry = dryAmount
        self.wet = wetAmount
    }
}
