// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

@testable import AudioKit
import AVFoundation
import Foundation
import GameplayKit
import SoundpipeAudioKit
import XCTest

func setParams(node: Node, rng: GKRandomSource) {
    for param in node.parameters {
        let def = param.def
        let size = def.range.upperBound - def.range.lowerBound
        let value = rng.nextUniform() * size + def.range.lowerBound
        print("setting parameter \(def.name) to \(value)")
        param.value = value
    }
}

class GenericNodeTests: XCTestCase {
    func nodeRandomizedTest(md5: String, factory: () -> Node, audition: Bool = false) {
        // We want determinism.
        let rng = GKMersenneTwisterRandomSource(seed: 0)

        let duration = 10
        let engine = AudioEngine()
        var bigBuffer: AVAudioPCMBuffer?

        for _ in 0 ..< duration {
            let node = factory()
            engine.output = node

            node.start()

            let audio = engine.startTest(totalDuration: 1.0)
            setParams(node: node, rng: rng)
            audio.append(engine.render(duration: 1.0))

            if bigBuffer == nil {
                bigBuffer = AVAudioPCMBuffer(pcmFormat: audio.format, frameCapacity: audio.frameLength * UInt32(duration))
            }

            bigBuffer?.append(audio)
        }

        XCTAssertFalse(bigBuffer!.isSilent)

        if audition { bigBuffer!.audition() }

        XCTAssertEqual(bigBuffer!.md5, md5)
    }

    func nodeParameterTest(md5: String, factory: () -> Node, m1MD5: String = "", audition: Bool = false) {
        let duration = factory().parameters.count + 1

        let engine = AudioEngine()
        var bigBuffer: AVAudioPCMBuffer?

        let node = factory()
        engine.output = node

        /// Do the default parameters first
        if bigBuffer == nil {
            let audio = engine.startTest(totalDuration: 1.0)
            audio.append(engine.render(duration: 1.0))
            bigBuffer = AVAudioPCMBuffer(pcmFormat: audio.format, frameCapacity: audio.frameLength * UInt32(duration))

            bigBuffer?.append(audio)
        }

        for i in 0 ..< factory().parameters.count {
            let node = factory()
            engine.output = node

            let param = node.parameters[i]

            node.start()

            param.value = param.def.range.lowerBound
            param.ramp(to: param.def.range.upperBound, duration: 1)

            let audio = engine.startTest(totalDuration: 1.0)
            audio.append(engine.render(duration: 1.0))

            bigBuffer?.append(audio)
        }

        XCTAssertFalse(bigBuffer!.isSilent)

        if audition {
            bigBuffer!.audition()
        }
        XCTAssertTrue([md5, m1MD5].contains(bigBuffer!.md5), "\(node) produced \(bigBuffer!.md5)")
    }

    let waveforms = [Table(.square), Table(.triangle), Table(.sawtooth), Table(.square)]

    func testGenerators() {
        nodeParameterTest(md5: "c446687403df3de7b35992072f657f2a", factory: { BrownianNoise() })
        nodeParameterTest(md5: "a6b349556557b75f9d3f85966ba3a86e", factory: { DynamicOscillator(waveform: Table(.square)) })
        nodeParameterTest(md5: "3022c1a134738aa06f3fa17e5cab936f", factory: { FMOscillator(waveform: Table(.triangle)) })
        nodeParameterTest(md5: "f5729296e26d370704b12054cc6c0e59", factory: { MorphingOscillator(waveformArray: waveforms) })
        nodeParameterTest(md5: "e204e8fba1d120e05bb4d4a92beff166", factory: { Oscillator(waveform: Table(.triangle)) })
        nodeParameterTest(md5: "d36549cd87f5e5b8160f2f164e6ddd60", factory: { PhaseDistortionOscillator(waveform: Table(.square)) })
        nodeParameterTest(md5: "8f0e118a673f137682f011cb27c2d545", factory: { PWMOscillator() })
        nodeParameterTest(md5: "9f9eaa3c7407f5770d65dab9da26bf81", factory: { PinkNoise() })
        nodeParameterTest(md5: "03936185395410ed642edf7320018b79", factory: { VocalTract() })
        nodeParameterTest(md5: "0750dcbb4f03fc82ee834692989d4f36", factory: { WhiteNoise() })

        #if os(macOS)
            nodeRandomizedTest(md5: "934b63edeb47e4dddda0bc90e1fd0499", factory: { BrownianNoise() })
        #endif
    }

    func testEffects() {
        let input = Oscillator(waveform: Table(.triangle))
        input.start()
        nodeParameterTest(md5: "ca6035230e8ead3adba789030683bdd8", factory: { AutoPanner(input, waveform: Table(.triangle)) })
        nodeParameterTest(md5: "621ee088c1722a006d68bcb59003f9b9", factory: { AutoWah(input) })
        nodeParameterTest(md5: "8a00598674f28991ff1851ff5524878f", factory: { BitCrusher(input) })
        nodeParameterTest(md5: "f4e8c6406ebe8292d7f7b4e8e1016654", factory: { ChowningReverb(input) })
        nodeParameterTest(md5: "bd8ee7cbd48b4d84a46a7d26b2634c9c", factory: { Clipper(input) })
        nodeParameterTest(md5: "9f99cc06ef1bb306072b7190e4f9620c", factory: { CombFilterReverb(input) })
        nodeParameterTest(md5: "080ed7f1201852bbe59d14542d0b638a", factory: { CostelloReverb(input) })
        nodeParameterTest(md5: "6b753433152f7e5bc7fb8b5f7978fa03", factory: { DCBlock(input) })
        nodeParameterTest(md5: "b5658c3dfb7fad49447bd47c087493a4", factory: { Decimator(input) })
        nodeParameterTest(md5: "1c6a2cca9fb8003d0394cd31f04e2c73", factory: { Distortion(input) })
        nodeParameterTest(md5: "f021e2d73f77e9135db39e64d83d7ca3", factory: { DynamicRangeCompressor(input) })
        nodeParameterTest(md5: "d4beabaa5a078be8b58eac0646083b52", factory: { EqualizerFilter(input) })
        nodeParameterTest(md5: "c54e61cf82b189a5fa78d0c1ab7c8bd2", factory: { FlatFrequencyResponseReverb(input) })
        nodeParameterTest(md5: "1cdeaae66b5ac2dd2a22fca36bcbd6c3", factory: { Panner(input) })
        nodeParameterTest(md5: "211e486ce67223097d0e94947a80967c", factory: { PitchShifter(input) })
        nodeParameterTest(md5: "513929644ed5475acadc4bd11d150391", factory: { RingModulator(input) })
        nodeParameterTest(md5: "39a3782d7bcf33ff32d75287f340aed2", factory: { StringResonator(input) })
        nodeParameterTest(md5: "9a085d0e3d640628b7bfdef9831b4b87", factory: { TanhDistortion(input) })
        nodeParameterTest(md5: "61ed8723ad0e3328995327a3e44cca7d", factory: { Tremolo(input) })
        nodeParameterTest(md5: "66d43bfddaed43cbc39c708fcfe1e795", factory: { VariableDelay(input) })

// Commented out for CI
//#if os(macOS)
//        nodeParameterTest(md5: "9531a8b5ed754e891a33b9620e5e51d8", factory: { ZitaReverb(input) })
//#else
//        nodeParameterTest(md5: "587990a1506e4fbe08eba8e01f824260", factory: { ZitaReverb(input) })
//#endif
    }

    func nodeParameterTest2(md5: String, factory: (Node) -> Node, m1MD5: String = "", audition: Bool = false) {
        let bundle = Bundle.module
        let url = bundle.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        let node = factory(player)

        let duration = node.parameters.count + 1

        let engine = AudioEngine()
        var bigBuffer: AVAudioPCMBuffer?

        engine.output = node

        /// Do the default parameters first
        if bigBuffer == nil {
            let audio = engine.startTest(totalDuration: 1.0)
            player.play()
            player.isLooping = true
            audio.append(engine.render(duration: 1.0))
            bigBuffer = AVAudioPCMBuffer(pcmFormat: audio.format, frameCapacity: audio.frameLength * UInt32(duration))

            bigBuffer?.append(audio)
        }

        for i in 0 ..< node.parameters.count {
            let node = factory(player)
            engine.output = node

            let param = node.parameters[i]

            node.start()

            param.value = param.def.range.lowerBound
            param.ramp(to: param.def.range.upperBound, duration: 1)

            let audio = engine.startTest(totalDuration: 1.0)
            audio.append(engine.render(duration: 1.0))

            bigBuffer?.append(audio)
        }

        XCTAssertFalse(bigBuffer!.isSilent)

        if audition {
            bigBuffer!.audition()
        }
        XCTAssertTrue([md5, m1MD5].contains(bigBuffer!.md5), "\(node) produced \(bigBuffer!.md5)")
    }

    func test2() {
        #if os(iOS)
            nodeParameterTest2(md5: "9c22ce220fc5e692f75179b16df27b78", factory: { player in Reverb(player) })
        #endif

        #if os(macOS)
            nodeParameterTest2(md5: "ac8d2c81f0c74217d3fff003cbf28d68", factory: { player in Reverb(player) })
        #endif
    }

    func testFilters() {
        let input = Oscillator(waveform: Table(.triangle))
        input.start()
        nodeParameterTest(md5: "ccd54837ff0c5e43c3e109bdeebf536d", factory: { BandPassButterworthFilter(input) })
        nodeParameterTest(md5: "5269a68db755b2f3a740c16108945ece", factory: { BandRejectButterworthFilter(input) })
        nodeParameterTest(md5: "d4beabaa5a078be8b58eac0646083b52", factory: { EqualizerFilter(input) })
        nodeParameterTest(md5: "eb78315658f5b47d1efc54743661f9db", factory: { FormantFilter(input) })
        nodeParameterTest(md5: "db115d0a67363d63cdf806fb705e123d", factory: { HighPassButterworthFilter(input) })
        nodeParameterTest(md5: "2b0525fb2c4494722e6caa57bd844a50", factory: { HighPassFilter(input) })
        nodeParameterTest(md5: "c127db941ea2763f985f6c1b9e8fbc63", factory: { HighShelfParametricEqualizerFilter(input) })
        nodeParameterTest(md5: "6034bbd516d8991157c26ca3fbf50841", factory: { KorgLowPassFilter(input) })
        nodeParameterTest(md5: "15a9cf33bdc66e48ecf03e3c23bc4eff", factory: { LowPassButterworthFilter(input) })
        nodeParameterTest(md5: "44c44f7cd35287b822b94e64fd1794f2", factory: { LowPassFilter(input) })
        nodeParameterTest(md5: "ec37b754f9684621885b6765b3ee5b53", factory: { LowShelfParametricEqualizerFilter(input) })
        nodeParameterTest(md5: "b56742711db2e02cfc1f6d9505a70765", factory: { ModalResonanceFilter(input) })
        nodeParameterTest(md5: "08404509b791b5400e9875e15ebe4ba7", factory: { MoogLadder(input) })
        nodeParameterTest(md5: "a5123dd3e94870179d3df1a87ca4235e", factory: { PeakingParametricEqualizerFilter(input) })
        nodeParameterTest(md5: "047f8d639df26b7516080c9c167cdb09", factory: { ResonantFilter(input) })
        nodeParameterTest(md5: "23717901359219d56b71061ef64c83ca", factory: { RolandTB303Filter(input) })
        nodeParameterTest(md5: "111a5ee7bda96639431b079965991162", factory: { ThreePoleLowpassFilter(input) })
        nodeParameterTest(md5: "683d879a69a0bf7a6e53823a85bd0db9", factory: { ToneComplementFilter(input) })
        nodeParameterTest(md5: "0eb55f05ad8f5b5c1e7f5c759ce123f4", factory: { ToneFilter(input) })
    }
}
