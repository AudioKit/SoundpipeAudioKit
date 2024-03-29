// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX

/// Emulation of the Roland TB-303 filter
public class RolandTB303Filter: Node {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "tb3f")

    // MARK: - Parameters

    /// Specification details for cutoffFrequency
    public static let cutoffFrequencyDef = NodeParameterDef(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency",
        address: akGetParameterAddress("RolandTB303FilterParameterCutoffFrequency"),
        defaultValue: 500,
        range: 12.0 ... 20000.0,
        unit: .hertz
    )

    /// Cutoff frequency. (in Hertz)
    @Parameter(cutoffFrequencyDef) public var cutoffFrequency: AUValue

    /// Specification details for resonance
    public static let resonanceDef = NodeParameterDef(
        identifier: "resonance",
        name: "Resonance",
        address: akGetParameterAddress("RolandTB303FilterParameterResonance"),
        defaultValue: 0.5,
        range: 0.0 ... 2.0,
        unit: .generic
    )

    /// Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
    @Parameter(resonanceDef) public var resonance: AUValue

    /// Specification details for distortion
    public static let distortionDef = NodeParameterDef(
        identifier: "distortion",
        name: "Distortion",
        address: akGetParameterAddress("RolandTB303FilterParameterDistortion"),
        defaultValue: 2.0,
        range: 0.0 ... 4.0,
        unit: .generic
    )

    /// Distortion. Value is typically 2.0; deviation from this can cause stability issues.
    @Parameter(distortionDef) public var distortion: AUValue

    /// Specification details for resonanceAsymmetry
    public static let resonanceAsymmetryDef = NodeParameterDef(
        identifier: "resonanceAsymmetry",
        name: "Resonance Asymmetry",
        address: akGetParameterAddress("RolandTB303FilterParameterResonanceAsymmetry"),
        defaultValue: 0.5,
        range: 0.0 ... 1.0,
        unit: .percent
    )

    /// Asymmetry of resonance. Value is between 0-1
    @Parameter(resonanceAsymmetryDef) public var resonanceAsymmetry: AUValue

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff frequency. (in Hertz)
    ///   - resonance: Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
    ///   - distortion: Distortion. Value is typically 2.0; deviation from this can cause stability issues.
    ///   - resonanceAsymmetry: Asymmetry of resonance. Value is between 0-1
    ///
    public init(
        _ input: Node,
        cutoffFrequency: AUValue = cutoffFrequencyDef.defaultValue,
        resonance: AUValue = resonanceDef.defaultValue,
        distortion: AUValue = distortionDef.defaultValue,
        resonanceAsymmetry: AUValue = resonanceAsymmetryDef.defaultValue
    ) {
        self.input = input

        setupParameters()

        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance
        self.distortion = distortion
        self.resonanceAsymmetry = resonanceAsymmetry
    }
}
