// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX
import Tonic

/// Pitch correction
public class PitchCorrect: Node {
    let input: Node
    
    public var key: Key {
        didSet {
            updateScaleFrequencies()
        }
    }
    
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
    ///   - key: Key to tune to
    ///   - scale: Scale to use (default: major)
    ///   - speed: Speed of pitch correction (0-1)
    ///   - amount: Amount of pitch correction (0-1)
    ///
    public init(
        _ input: Node,
        key: Key = .C,
        speed: AUValue = speedDef.defaultValue,
        amount: AUValue = amountDef.defaultValue
    ) {
        self.input = input
        self.key = key
        
        updateScaleFrequencies()
        
        setupParameters()

        self.speed = speed
        self.amount = amount
        
        updateScaleFrequencies()
    }
    
    /// Update the scale frequencies based on current key and scale
    private func updateScaleFrequencies() {
        var frequencies: [Float] = []
        
        // Generate notes for octaves 0 through 7
        for octave in 0...7 {
            for noteClass in key.noteSet.noteClassSet.array {
                let noteWithOctave = Note(noteClass.letter, accidental: noteClass.accidental, octave: octave)
                frequencies.append(UInt8(noteWithOctave.pitch.midiNoteNumber).midiNoteToFrequency())
            }
        }
        
        // Sort frequencies in ascending order
        frequencies.sort()
        
        // Set the frequencies in the DSP
        setScaleFrequencies(frequencies)
    }
    
    /// Set the scale frequencies for pitch correction
    /// - Parameter frequencies: Array of frequencies in Hz
    public func setScaleFrequencies(_ frequencies: [Float]) {
        au.setWavetable(frequencies)
    }
}
