// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX

/// Vibrato with adjustable speed and depth
public class Vibrato: Node {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "vbrt")

    // MARK: - Parameters

    /// Specification details for speed
    public static let speedDef = NodeParameterDef(
        identifier: "speed",
        name: "Speed",
        address: akGetParameterAddress("VibratoParameterSpeed"),
        defaultValue: 1,
        range: 0.0 ... 100.0,
        unit: .hertz
    )

    /// Speed (frequency) of vibrato
    @Parameter(speedDef) public var speed: AUValue

    /// Specification details for depth
    public static let depthDef = NodeParameterDef(
        identifier: "depth",
        name: "Depth",
        address: akGetParameterAddress("VibratoParameterDepth"),
        defaultValue: 1,
        range: 0.0 ... 24.0,
        unit: .relativeSemiTones
    )

    /// Depth (amplitude) of vibrato in semitones
    @Parameter(depthDef) public var depth: AUValue

    // MARK: - Initialization

    /// Initialize this vibrato node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - speed: Speed (frequency) of vibrato (Hz)
    ///   - depth: Depth (amplitude) of vibrato (semitones)
    ///
    public init(
        _ input: Node,
        speed: AUValue = speedDef.defaultValue,
        depth: AUValue = depthDef.defaultValue
    ) {
        self.input = input

        setupParameters()

        self.speed = speed
        self.depth = depth
    }
}
