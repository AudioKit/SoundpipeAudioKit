// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX

/// Stereo Panner
public class Panner: Node {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var auAudioUnit: AUAudioUnit = instantiateAU(componentDescription: .init(effect: "pan2"))

    // MARK: - Parameters

    /// Specification details for pan
    public static let panDef = NodeParameterDef(
        identifier: "pan",
        name: "Pan",
        address: akGetParameterAddress("PannerParameterPan"),
        defaultValue: 0,
        range: -1 ... 1,
        unit: .generic
    )

    /// Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    @Parameter(panDef) public var pan: AUValue

    // MARK: - Initialization

    /// Initialize this panner node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - pan: Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    ///
    public init(
        _ input: Node,
        pan: AUValue = panDef.defaultValue
    ) {
        self.input = input

        setupParameters()

        self.pan = pan
    }
}
