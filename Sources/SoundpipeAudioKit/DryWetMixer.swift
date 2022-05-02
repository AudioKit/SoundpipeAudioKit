// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import AudioKit
import AudioKitEX
import CAudioKitEX

/// Balanceable Mix between two signals, usually used for a dry signal and wet signal
///
public class DryWetMixer: Node {

    private let mix: DryWetDualMixer
    
    /// Connected nodes
    public var connections: [Node] { mix.connections }

    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode { mix.avAudioNode }

    // MARK: - Parameters

    /// Balance between input signals
    public var balance: AUValue {
        get { mix.wet }
        set {
            mix.wet = newValue
            mix.dry = 1 - newValue
        }
    }

    /// Initialize this dry wet mixer node
    ///
    /// - Parameters:
    ///   - input1: 1st source
    ///   - input2: 2nd source
    ///   - balance: Balance Point (0 = all input1, 1 = all input2)
    ///
    public init(_ input1: Node, _ input2: Node, balance: AUValue = 0.5) {
        self.mix = DryWetDualMixer(input1, input2)
        
        setupParameters()
        
        self.balance = balance
        self.mix.dry = 1 - balance
        self.mix.wet = balance
    }

    /// Initializer with dry wet labels
    /// - Parameters:
    ///   - dry: Input 1
    ///   - wet: Input 2
    ///   - balance: Balance between inputs
    public convenience init(dry: Node, wet: Node, balance: AUValue = 0.5) {
        self.init(dry, wet, balance: balance)
    }

}
