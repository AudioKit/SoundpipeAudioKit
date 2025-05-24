// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX

/// Pitch correction
public class PitchCorrect: Node {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "pcrt")

    // MARK: - Parameters

    /// Specification details for speed
    public static let speedDef = NodeParameterDef(
        identifier: "speed",
        name: "Speed",
        address: akGetParameterAddress("PitchCorrectParameterSpeed"),
        defaultValue: 0.5,
        range: 0.0 ... 1.0,
        unit: .generic
    )

    /// Speed of pitch correction (0-1)
    @Parameter(speedDef) public var speed: AUValue

    /// Specification details for amount
    public static let amountDef = NodeParameterDef(
        identifier: "amount",
        name: "Amount",
        address: akGetParameterAddress("PitchCorrectParameterAmount"),
        defaultValue: 1.0,
        range: 0.0 ... 1.0,
        unit: .generic
    )

    /// Amount of pitch correction (0-1)
    @Parameter(amountDef) public var amount: AUValue

    // MARK: - Initialization

    /// Initialize this pitch correction node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - speed: Speed of pitch correction (0-1)
    ///   - amount: Amount of pitch correction (0-1)
    ///
    public init(
        _ input: Node,
        speed: AUValue = speedDef.defaultValue,
        amount: AUValue = amountDef.defaultValue
    ) {
        self.input = input

        setupParameters()

        self.speed = speed
        self.amount = amount
    }
}
