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
        nodeParameterTest(md5: "91982383233dc367491b40704c803bb8", factory: { BrownianNoise() })
        nodeParameterTest(md5: "7908317b75b7653edbc3965601d2fce4", factory: { DynamicOscillator(waveform: Table(.square)) })
        nodeParameterTest(md5: "39c71461b484ee7b9f9e95adf6e60b97", factory: { FMOscillator(waveform: Table(.triangle)) })
        nodeParameterTest(md5: "9430e242d470c60e24fa92f75b62d83c", factory: { MorphingOscillator(waveformArray: waveforms) })
        nodeParameterTest(md5: "47fee9e7eeb6bad4537a6ed20fd3e252", factory: { Oscillator(waveform: Table(.triangle)) })
        nodeParameterTest(md5: "b701c534d239054d31a6e80f52c29280", factory: { PhaseDistortionOscillator(waveform: Table(.square)) })
        nodeParameterTest(md5: "35e44d5c3204d3ed0675513d06f4c6f1", factory: { PWMOscillator() })
        nodeParameterTest(md5: "f7902a87db79789c0b8f1d2e5e59e7b5", factory: { PinkNoise() })
        nodeParameterTest(md5: "26c79b1047504661836ab0638c10c7a1", factory: { VocalTract() })
        nodeParameterTest(md5: "6fc97b719ed8138c53464db8f09f937e", factory: { WhiteNoise() })

        #if os(macOS)
            nodeRandomizedTest(md5: "934b63edeb47e4dddda0bc90e1fd0499", factory: { BrownianNoise() })
        #endif
    }

    func testEffects() {
        let input = Oscillator(waveform: Table(.triangle))
        input.start()
        nodeParameterTest(md5: "14fffc4691ab7c030fc87cbe7cb8a740", factory: { AutoPanner(input, waveform: Table(.triangle)) })
        nodeParameterTest(md5: "a1593a3dd9e90a3b3fe85b9966f463c9", factory: { AutoWah(input) })
        nodeParameterTest(md5: "9694111ab050578c2bd193090bc72e1a", factory: { BitCrusher(input) })
        nodeParameterTest(md5: "9aaf3ffb33620e3ea5321cd27f45db02", factory: { ChowningReverb(input) })
        nodeParameterTest(md5: "56e76b5bd1d59d77ad4bd670f605f191", factory: { Clipper(input) })
        nodeParameterTest(md5: "d44f6c167ba10c20058067da0f8f5d61", factory: { CombFilterReverb(input) })
        nodeParameterTest(md5: "7bc6e1d3471a2a739206d6c88817d8c4", factory: { CostelloReverb(input) })
        nodeParameterTest(md5: "cd3977c4d4b0d2bf84e1265476b5fd52", factory: { DCBlock(input) })
        nodeParameterTest(md5: "055e61433dd9d8f55c36d9d7f1cdfaca", factory: { Decimator(input) })
        nodeParameterTest(md5: "c52e623c413068f6a10e0a691734fb44", factory: { Distortion(input) })
        nodeParameterTest(md5: "719e6af71973aa926ed88912f004a1b1", factory: { DynamicRangeCompressor(input) })
        nodeParameterTest(md5: "136f117419523de4082275e74613d3e9", factory: { EqualizerFilter(input) })
        nodeParameterTest(md5: "42dc82f5e690fe15580ba3d5d8bf74d9", factory: { FlatFrequencyResponseReverb(input) })
        nodeParameterTest(md5: "2d0be43f2de761df1627e7fc1eef4e41", factory: { Panner(input) })
        nodeParameterTest(md5: "e79d5fa3445956f51fc220bfa2b60774", factory: { PitchShifter(input) })
        nodeParameterTest(md5: "04f8b15b4d0efc632859cbc67cf517e4", factory: { RingModulator(input) })
        nodeParameterTest(md5: "05f14f7862000b8ba4bed5802cd51eaf", factory: { StringResonator(input) })
        nodeParameterTest(md5: "3838887f913f1f75cacca49f31096381", factory: { TanhDistortion(input) })
        nodeParameterTest(md5: "83c95cde57bf85e670e488e1ff2daece", factory: { Tremolo(input) })
        nodeParameterTest(md5: "4252aa6f4c43e7be1fbdb5a55de3d8f8", factory: { VariableDelay(input) })
        nodeParameterTest(md5: "9531a8b5ed754e891a33b9620e5e51d8", factory: { ZitaReverb(input) })
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
            nodeParameterTest2(md5: "28d2cb7a5c1e369ca66efa8931d31d4d", factory: { player in Reverb(player) })
        #endif

        #if os(macOS)
            nodeParameterTest2(md5: "ac8d2c81f0c74217d3fff003cbf28d68", factory: { player in Reverb(player) })
        #endif
    }

    func testFilters() {
        let input = Oscillator(waveform: Table(.triangle))
        input.start()
        nodeParameterTest(md5: "697dd230db3f7d93d4cc32939fd4b203", factory: { BandPassButterworthFilter(input) })
        nodeParameterTest(md5: "a879dc3594f6ca2872a681aaadd7464b", factory: { BandRejectButterworthFilter(input) })
        nodeParameterTest(md5: "136f117419523de4082275e74613d3e9", factory: { EqualizerFilter(input) })
        nodeParameterTest(md5: "c388dff62c69e2bf0d2ccdc8f07cf300", factory: { FormantFilter(input) })
        nodeParameterTest(md5: "42647b2d15d1d256bb2eecc57c4669b7", factory: { HighPassButterworthFilter(input) })
        nodeParameterTest(md5: "d4afdab94f658685c619d78de143788a", factory: { HighPassFilter(input) })
        nodeParameterTest(md5: "c6103d7b01e0cbecd3242c74b5f5b43d", factory: { HighShelfParametricEqualizerFilter(input) })
        nodeParameterTest(md5: "b5835dd370fcfa57987fcd9f73bf3867", factory: { KorgLowPassFilter(input) })
        nodeParameterTest(md5: "60ed3b21f000093e2dbbfa1fe47190ef", factory: { LowPassButterworthFilter(input) })
        nodeParameterTest(md5: "239a27564071e55fff0b686db03876a7", factory: { LowPassFilter(input) })
        nodeParameterTest(md5: "c8584e305d549a7f7c437a43986d486a", factory: { LowShelfParametricEqualizerFilter(input) })
        nodeParameterTest(md5: "5b05b6ec7ab84d1d2ec779ea678dc1bd", factory: { ModalResonanceFilter(input) })
        nodeParameterTest(md5: "28c4f2d31cb50cd5178dcf2246f2eee2", factory: { MoogLadder(input) })
        nodeParameterTest(md5: "5377211c724ab9e24174a942e0d0ea65", factory: { PeakingParametricEqualizerFilter(input) })
        nodeParameterTest(md5: "eff13db00a969ff92ff6421fd823b024", factory: { ResonantFilter(input) })
        nodeParameterTest(md5: "47952d3c73b82e51f9b69ec15038b54f", factory: { RolandTB303Filter(input) })
        nodeParameterTest(md5: "eb7ffdc0983e51fb71f34cff1fcb8af4", factory: { ThreePoleLowpassFilter(input) })
        nodeParameterTest(md5: "07d273778dbfd330232657f140bbf578", factory: { ToneComplementFilter(input) })
        nodeParameterTest(md5: "5c186ab1b56d539ab22a9b8b20119ebf", factory: { ToneFilter(input) })
    }
}
