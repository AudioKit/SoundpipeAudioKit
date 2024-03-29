// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX

/// This is was built using the JC reverb implementation found in FAUST.
/// According to the source code, the specifications for this implementation were
/// found on an old SAIL DART backup tape.
///
/// This class is derived from the CLM JCRev function, which is based on the use of
/// networks of simple allpass and comb delay filters.  This class implements three series
/// allpass units, followed by four parallel comb filters, and two decorrelation delay lines in
/// parallel at the output.
///
public class ChowningReverb: Node {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "jcrv")

    // MARK: - Parameters

    /// Dry/wet mix.
    public static let balanceDef = NodeParameterDef(
        identifier: "balance",
        name: "Balance",
        address: akGetParameterAddress("ChowningReverbParameterBalance"),
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
    ///
    public init(
        _ input: Node,
        balance: AUValue = balanceDef.defaultValue
    ) {
        self.input = input

        setupParameters()

        self.balance = balance
    }
}
