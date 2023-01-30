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
        nodeParameterTest(md5: "4aee27769cfaed6f4abcf6348ac29e95", factory: { DynamicOscillator(waveform: Table(.square)) })
        nodeParameterTest(md5: "d9f942578b818e5028d7040a12721f97", factory: { FMOscillator(waveform: Table(.triangle)) })
        nodeParameterTest(md5: "01072e25418a79c82b58d4bfe69e5375", factory: { MorphingOscillator(waveformArray: waveforms) })
        nodeParameterTest(md5: "ecdc68d433f767140b7f5f61b343ac21", factory: { Oscillator(waveform: Table(.triangle)) })
        nodeParameterTest(md5: "0ef5939e306673edd6809f030e28ce16", factory: { PhaseDistortionOscillator(waveform: Table(.square)) })
        nodeParameterTest(md5: "5d7c77114f863ec66aeffaf1243ae9c8", factory: { PWMOscillator() })
        nodeParameterTest(md5: "afdce4990f72e668f088765fabc90f0a", factory: { PinkNoise() })
        nodeParameterTest(md5: "25da4d13733e7c50e3b9706e028c452d", factory: { VocalTract() })
        nodeParameterTest(md5: "6fc97b719ed8138c53464db8f09f937e", factory: { WhiteNoise() })

        #if os(macOS)
            nodeRandomizedTest(md5: "999a7c4d39edf55550b2b4ef01ae1860", factory: { BrownianNoise() })
        #endif
    }

    func testEffects() {
        let input = Oscillator(waveform: Table(.triangle))
        input.start()
        nodeParameterTest(md5: "b67881dcf5c17fed56a9997ccc0a5161", factory: { AutoPanner(input, waveform: Table(.triangle)) })
        nodeParameterTest(md5: "d35074473678f32b4ba7c54e635b2766", factory: { AutoWah(input) })
        nodeParameterTest(md5: "55d5e818c9e8e3d6bfe1b029b6857ed3", factory: { BitCrusher(input) })
        nodeParameterTest(md5: "48a55d3d683d9d773ba4b04d0774a8c4", factory: { ChowningReverb(input) })
        nodeParameterTest(md5: "56e76b5bd1d59d77ad4bd670f605f191", factory: { Clipper(input) })
        nodeParameterTest(md5: "c9ab35b7818db6a9af4edfbe2cb83927", factory: { CombFilterReverb(input) })
        nodeParameterTest(md5: "bfdb04ada04582bac1c59626207726c2", factory: { CostelloReverb(input) })
        nodeParameterTest(md5: "6d17509eee0059105454f3cad4499586", factory: { DCBlock(input) })
        nodeParameterTest(md5: "fd4e315defe463bd643dd0c797cfd1f2", factory: { Decimator(input) })
        nodeParameterTest(md5: "4e240310041e20bdc886dd5eb285e89c", factory: { Distortion(input) })
        nodeParameterTest(md5: "a245e060a95fa63f70f01633eb00db0b", factory: { DynamicRangeCompressor(input) })
        nodeParameterTest(md5: "5c34d6b545a441037cea3126db3725c3", factory: { EqualizerFilter(input) })
        nodeParameterTest(md5: "b2eac657e060927cd0b3bfd74817c99e", factory: { FlatFrequencyResponseReverb(input) })
        nodeParameterTest(md5: "a6c3c2cdc02e77c1d71bcab22b70982c", factory: { Panner(input) })
        nodeParameterTest(md5: "95ba7a1fbd8c85c129999d20a0653dfe", factory: { PitchShifter(input) })
        nodeParameterTest(md5: "547cc8833929d40042a0a00566cc032f", factory: { RingModulator(input) })
        nodeParameterTest(md5: "56ce31a64d0c7488e814cd16e09ea378", factory: { StringResonator(input) })
        nodeParameterTest(md5: "7ce66baf0b5a272dc83db83f443bd1d8", factory: { TanhDistortion(input) })
        nodeParameterTest(md5: "6a54cda833433325a5bd885c1375c6e2", factory: { Tremolo(input) }, m1MD5: "bb704255aad8df505d427fea08d57246")
        nodeParameterTest(md5: "17b152691ddaca9a74a5ab086db0e546", factory: { VariableDelay(input) })
        nodeParameterTest(md5: "88abdd2849431c26dab746666fcc7dbc", factory: { ZitaReverb(input) }, m1MD5: "489a410a70b87390bdc84f9f881bd260")
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
            nodeParameterTest2(md5: "bff0b5fa57e589f5192b17194d9a43cb", factory: { player in Reverb(player) })
        #endif
    }

    func testFilters() {
        let input = Oscillator(waveform: Table(.triangle))
        input.start()
        nodeParameterTest(md5: "e21144303552ef8ba518582788c3ea1f", factory: { BandPassButterworthFilter(input) })
        nodeParameterTest(md5: "cbc23ff6ee40c12b0348866402d9fac3", factory: { BandRejectButterworthFilter(input) })
        nodeParameterTest(md5: "5c34d6b545a441037cea3126db3725c3", factory: { EqualizerFilter(input) })
        nodeParameterTest(md5: "433c45f0211948ecaa8bfd404963af7b", factory: { FormantFilter(input) })
        nodeParameterTest(md5: "9b38c130c6faf04b5b168d6979557a3f", factory: { HighPassButterworthFilter(input) })
        nodeParameterTest(md5: "4120a8fefb4efe8f455bc8c001ab1538", factory: { HighPassFilter(input) })
        nodeParameterTest(md5: "5aaeb38a15503c162334f0ec1bfacfcd", factory: { HighShelfFilter(input) })
        nodeParameterTest(md5: "b4c47d9ad07ccf556accb05336c52469", factory: { HighShelfParametricEqualizerFilter(input) })
        nodeParameterTest(md5: "6790ba0e808cc8e49f1a609b05b5c490", factory: { KorgLowPassFilter(input) })
        nodeParameterTest(md5: "ce2bd006a13317b11a460a12ad343835", factory: { LowPassButterworthFilter(input) })
        nodeParameterTest(md5: "aeec895e45341249b7fc23ea688dfba8", factory: { LowPassFilter(input) })
        nodeParameterTest(md5: "2f81a7a8c9325863b4afa312ca066ed8", factory: { LowShelfFilter(input) })
        nodeParameterTest(md5: "2f7e88b1835845342b0c8cca9930cb5c", factory: { LowShelfParametricEqualizerFilter(input) })
        nodeParameterTest(md5: "5638bd8e112d88fa1053154dc0027152", factory: { ModalResonanceFilter(input) }, m1MD5: "0db12817a5def3a82d0d28fc0c3f8ab9")
        nodeParameterTest(md5: "535192bcc8107d22dae9273f284b1bc5", factory: { MoogLadder(input) })
        nodeParameterTest(md5: "3a0b95902029e33a5b80b3a3baf6f8a7", factory: { PeakingParametricEqualizerFilter(input) })
        nodeParameterTest(md5: "06ebb0f4defb20ef2213ec60acf60620", factory: { ResonantFilter(input) })
        nodeParameterTest(md5: "800b4a050e83cf6fe73d2561a973c879", factory: { RolandTB303Filter(input) }, m1MD5: "c0f44f67e4ba3f3265fb536109126eb4")
        nodeParameterTest(md5: "44273d78d701be87ec9613ace6a179cd", factory: { ThreePoleLowpassFilter(input) })
        nodeParameterTest(md5: "84c3dcb52f76610e0c0ed9b567248fa1", factory: { ToneComplementFilter(input) })
        nodeParameterTest(md5: "f4b3774bdc83f2220b33ed7de360a184", factory: { ToneFilter(input) })
    }
}
