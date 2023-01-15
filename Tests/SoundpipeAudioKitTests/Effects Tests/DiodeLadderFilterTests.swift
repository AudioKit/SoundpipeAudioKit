// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/SoundpipeAudioKit/

import AudioKit
import SoundpipeAudioKit
import XCTest

class DiodeLadderFilterTests: XCTestCase {
    func testBypass() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.sine),
                               frequency: 440,
                               amplitude: 1.0,
                               detuningOffset: 0.0,
                               detuningMultiplier: 1.0)
        let filter = DiodeLadderFilter(input)

        engine.output = filter

        input.start()

        let audio = engine.startTest(totalDuration: 2.0)

        let originalAudio = engine.render(duration: 1.0)
        audio.append(originalAudio)

        filter.bypass()

        let bypassedAudio = engine.render(duration: 1.0)
        audio.append(bypassedAudio)

        guard let originalAudioPeak = originalAudio.peak()?.amplitude else {
            XCTFail("The audio data appears to have no peak")
            return
        }
        guard let bypassedAudioPeak = bypassedAudio.peak()?.amplitude else {
            XCTFail("The audio data appears to have no peak")
            return
        }
        XCTAssertNotEqual(originalAudioPeak, bypassedAudioPeak, accuracy: 0.01)

        testMD5(audio)
    }
    func testInitialParameterValues() {
        let input = Oscillator(waveform: Table(.sine),
                               frequency: 440,
                               amplitude: 1.0,
                               detuningOffset: 0.0,
                               detuningMultiplier: 1.0)
        let filter = DiodeLadderFilter(input)

        guard let filterParamTree = filter.au.parameterTree else {
            XCTFail("No parameter tree found")
            return
        }

        let cutoffFrequencyAddress = DiodeLadderFilter.cutoffFrequencyDef.address
        let resonanceAddress = DiodeLadderFilter.resonanceDef.address
        guard let cutoffFrequencyParam = filterParamTree.parameter(withAddress: cutoffFrequencyAddress) else {
            XCTFail("Parameter address not found for: \(DiodeLadderFilter.cutoffFrequencyDef.name)")
            return
        }
        guard let resonanceParam = filterParamTree.parameter(withAddress: resonanceAddress) else {
            XCTFail("Parameter address not found for: \(DiodeLadderFilter.resonanceDef.name)")
            return
        }

        XCTAssertEqual(cutoffFrequencyParam.value, DiodeLadderFilter.cutoffFrequencyDef.defaultValue)
        XCTAssertEqual(filter.cutoffFrequency, DiodeLadderFilter.cutoffFrequencyDef.defaultValue)
        XCTAssertEqual(resonanceParam.value, DiodeLadderFilter.resonanceDef.defaultValue)
        XCTAssertEqual(filter.resonance, DiodeLadderFilter.resonanceDef.defaultValue)
    }
    func testParameterRamping() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.sine),
                               frequency: 440,
                               amplitude: 1.0,
                               detuningOffset: 0.0,
                               detuningMultiplier: 1.0)
        let filter = DiodeLadderFilter(input)

        guard let filterParamTree = filter.au.parameterTree else {
            XCTFail("No parameter tree found")
            return
        }

        let cutoffFrequencyAddress = DiodeLadderFilter.cutoffFrequencyDef.address
        let resonanceAddress = DiodeLadderFilter.resonanceDef.address
        guard let cutoffFrequencyParam = filterParamTree.parameter(withAddress: cutoffFrequencyAddress) else {
            XCTFail("Parameter address not found for: \(DiodeLadderFilter.cutoffFrequencyDef.name)")
            return
        }
        guard let resonanceParam = filterParamTree.parameter(withAddress: resonanceAddress) else {
            XCTFail("Parameter address not found for: \(DiodeLadderFilter.resonanceDef.name)")
            return
        }

        engine.output = filter

        input.start()

        let audio = engine.startTest(totalDuration: 1.0)

        let initialFreq: AUValue = 12.0
        let finalFreq: AUValue = 500.0
        let initialRes: AUValue = 0.2
        let finalRes: AUValue = 1.0
        let duration: Float = 1.0

        filter.$cutoffFrequency.ramp(from: initialFreq, to: finalFreq, duration: duration)
        filter.$resonance.ramp(from: initialRes, to: finalRes, duration: duration)

        audio.append(engine.render(duration: 0.02))
        wait(for: 0.02)

        XCTAssertEqual(filter.cutoffFrequency, initialFreq)
        XCTAssertEqual(cutoffFrequencyParam.value, initialFreq)
        XCTAssertEqual(filter.resonance, initialRes)
        XCTAssertEqual(resonanceParam.value, initialRes)

        audio.append(engine.render(duration: 0.98))

        XCTAssertEqual(filter.cutoffFrequency, finalFreq)
        XCTAssertEqual(cutoffFrequencyParam.value, finalFreq)
        XCTAssertEqual(filter.resonance, finalRes)
        XCTAssertEqual(resonanceParam.value, finalRes)

        testMD5(audio)
    }
    func testReset() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.sine),
                               frequency: 440,
                               amplitude: 1.0,
                               detuningOffset: 0.0,
                               detuningMultiplier: 1.0)
        let filter = DiodeLadderFilter(input)

        engine.output = filter

        input.start()

        let audio = engine.startTest(totalDuration: 2.0)
        guard let sampleRate = engine.mainMixerNode?.outputFormat.sampleRate else {
            XCTFail("No sample rate to render audio")
            return
        }
        if sampleRate == 0 {
            XCTFail("Can't render audio with 0 Hz sample rate")
        }

        audio.append(engine.render(duration: 1.0))
        XCTAssertEqual(audio.toFloatChannelData()?[0].count, Int(sampleRate))

        filter.reset()

        audio.append(engine.render(duration: 1.0))
        XCTAssertEqual(audio.toFloatChannelData()?[0].count, Int(sampleRate) * 2)

        testMD5(audio)
    }
    func testSampleRateChange() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.sine),
                               frequency: 440,
                               amplitude: 1.0,
                               detuningOffset: 0.0,
                               detuningMultiplier: 1.0)
        let filter = DiodeLadderFilter(input)

        engine.output = filter

        input.start()

        let audio = engine.startTest(totalDuration: 2.090909090909091)
        guard let sampleRate = engine.mainMixerNode?.outputFormat.sampleRate else {
            XCTFail("No sample rate to render audio")
            return
        }
        if sampleRate == 0 {
            XCTFail("Can't render audio with 0 Hz sample rate")
        }

        XCTAssertEqual(sampleRate, Settings.sampleRate)

        audio.append(engine.render(duration: 1.0))
        XCTAssertEqual(audio.toFloatChannelData()?[0].count, Int(sampleRate))

        Settings.sampleRate = 48000

        guard let newSampleRate = engine.mainMixerNode?.outputFormat.sampleRate else {
            XCTFail("No sample rate to render audio")
            return
        }
        XCTAssertEqual(Settings.sampleRate, newSampleRate)

        audio.append(engine.render(duration: 1.0))
        XCTAssertEqual(audio.toFloatChannelData()?[0].count, Int(sampleRate) + Int(newSampleRate))

        testMD5(audio)
        Settings.sampleRate = 44100 // Put this back to default for other tests
    }
    // for waiting in the background for realtime testing
    func wait(for interval: TimeInterval) {
        let delayExpectation = XCTestExpectation(description: "delayExpectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            delayExpectation.fulfill()
        }
        wait(for: [delayExpectation], timeout: interval + 1)
    }
}
