

// Copyright AudioKit. All Rights Reserved.

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX

/// 16-band channel vocoder
///
public class Vocoder: Node {
    let input: Node
    let excitation: Node

    /// Connected nodes
    public var connections: [Node] { [input, excitation] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "vcdr")

    // MARK: - Parameters

    /// Attack time (0.001 to 0.5 seconds)
    public static let attackTimeDef = NodeParameterDef(
        identifier: "atk",
        name: "Attack Time",
        address: akGetParameterAddress("VocoderParameterAttackTime"),
        defaultValue: 0.1,
        range: 0.001 ... 0.5,
        unit: .seconds
    )

    /// Release time
    public static let releaseTimeDef = NodeParameterDef(
        identifier: "rel",
        name: "Release Time",
        address: akGetParameterAddress("VocoderParameterReleaseTime"),
        defaultValue: 0.1,
        range: 0.001 ... 0.5,
        unit: .seconds
    )

    /// Bandwidth ratio (0.1 to 2.0)
    public static let bandwidthRatioDef = NodeParameterDef(
        identifier: "bwratio",
        name: "Bandwidth Ratio",
        address: akGetParameterAddress("VocoderParameterBandwidthRatio"),
        defaultValue: 0.5,
        range: 0.1 ... 2.0,
        unit: .generic
    )

    /// Attack time (seconds)
    @Parameter(attackTimeDef) public var attackTime: AUValue

    /// Release time (seconds)
    @Parameter(releaseTimeDef) public var releaseTime: AUValue

    /// Bandwidth ratio
    @Parameter(bandwidthRatioDef) public var bandwidthRatio: AUValue

    // MARK: - Initialization

    /// Initialize this vocoder node
    ///
    /// - Parameters:
    ///   - input: Source signal (carrier)
    ///   - excitation: Excitation signal (modulator)
    ///   - attackTime: Attack time (0.001 to 0.5 seconds)
    ///   - releaseTime: Release time (0.001 to 0.5 seconds)
    ///   - bandwidthRatio: Bandwidth ratio (0.1 to 2.0)
    ///
    public init(
        _ input: Node,
        excitation: Node,
        attackTime: AUValue = attackTimeDef.defaultValue,
        releaseTime: AUValue = releaseTimeDef.defaultValue,
        bandwidthRatio: AUValue = bandwidthRatioDef.defaultValue
    ) {
        self.input = input
        self.excitation = excitation

        setupParameters()

        self.attackTime = attackTime
        self.releaseTime = releaseTime
        self.bandwidthRatio = bandwidthRatio
    }
}

