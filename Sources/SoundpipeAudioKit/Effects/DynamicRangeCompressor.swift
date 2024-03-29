// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX

/// Dynamic range compressor from Faust
public class DynamicRangeCompressor: Node {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "cpsr")

    // MARK: - Parameters

    /// Specification details for ratio
    public static let ratioDef = NodeParameterDef(
        identifier: "ratio",
        name: "Ratio",
        address: akGetParameterAddress("DynamicRangeCompressorParameterRatio"),
        defaultValue: 1,
        range: 0.01 ... 100.0,
        unit: .hertz
    )

    /// Ratio to compress with, a value > 1 will compress
    @Parameter(ratioDef) public var ratio: AUValue

    /// Specification details for threshold
    public static let thresholdDef = NodeParameterDef(
        identifier: "threshold",
        name: "Threshold",
        address: akGetParameterAddress("DynamicRangeCompressorParameterThreshold"),
        defaultValue: 0.0,
        range: -100.0 ... 0.0,
        unit: .generic
    )

    /// Threshold (in dB) 0 = max
    @Parameter(thresholdDef) public var threshold: AUValue

    /// Specification details for attackDuration
    public static let attackDurationDef = NodeParameterDef(
        identifier: "attackDuration",
        name: "Attack duration",
        address: akGetParameterAddress("DynamicRangeCompressorParameterAttackDuration"),
        defaultValue: 0.1,
        range: 0.0 ... 1.0,
        unit: .seconds
    )

    /// Attack duration
    @Parameter(attackDurationDef) public var attackDuration: AUValue

    /// Specification details for releaseDuration
    public static let releaseDurationDef = NodeParameterDef(
        identifier: "releaseDuration",
        name: "Release duration",
        address: akGetParameterAddress("DynamicRangeCompressorParameterReleaseDuration"),
        defaultValue: 0.1,
        range: 0.0 ... 1.0,
        unit: .seconds
    )

    /// Release Duration
    @Parameter(releaseDurationDef) public var releaseDuration: AUValue

    // MARK: - Initialization

    /// Initialize this compressor node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - ratio: Ratio to compress with, a value > 1 will compress
    ///   - threshold: Threshold (in dB) 0 = max
    ///   - attackDuration: Attack duration
    ///   - releaseDuration: Release Duration
    ///
    public init(
        _ input: Node,
        ratio: AUValue = ratioDef.defaultValue,
        threshold: AUValue = thresholdDef.defaultValue,
        attackDuration: AUValue = attackDurationDef.defaultValue,
        releaseDuration: AUValue = releaseDurationDef.defaultValue
    ) {
        self.input = input

        setupParameters()

        self.ratio = ratio
        self.threshold = threshold
        self.attackDuration = attackDuration
        self.releaseDuration = releaseDuration
    }
}
