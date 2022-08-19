// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import CAudioKitEX
import SoundpipeAudioKit
import XCTest

class OscillatorAutomationTests: XCTestCase {
    func testNewAutomationFrequency() {
        let engine = AudioEngine()
        let oscillator = Oscillator(waveform: Table(.square), frequency: 400, amplitude: 0.5)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        let event = AutomationEvent(targetValue: 880, startTime: 0, rampDuration: 1.0)
        oscillator.$frequency.automate(events: [event])
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNewAutomationAmplitude() {
        let engine = AudioEngine()
        let oscillator = Oscillator(waveform: Table(.square), frequency: 400, amplitude: 0.0)

        engine.output = oscillator

        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        let event = AutomationEvent(targetValue: 1.0, startTime: 0, rampDuration: 1.0)
        oscillator.$amplitude.automate(events: [event])
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNewAutomationMultiple() {
        let engine = AudioEngine()
        let oscillator = Oscillator(waveform: Table(.square), frequency: 400, amplitude: 0.0)

        engine.output = oscillator

        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)

        let frequencyEvent = AutomationEvent(targetValue: 880, startTime: 0, rampDuration: 1.0)
        oscillator.$frequency.automate(events: [frequencyEvent])

        let amplitudeEvent = AutomationEvent(targetValue: 1.0, startTime: 0, rampDuration: 1.0)
        oscillator.$amplitude.automate(events: [amplitudeEvent])
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNewAutomationDelayed() {
        let engine = AudioEngine()
        let oscillator = Oscillator(waveform: Table(.triangle), frequency: 400, amplitude: 0.5)
        engine.output = oscillator

        oscillator.start()
        let audio = engine.startTest(totalDuration: 2.0)

        // Delay a second.
        let startTime = AVAudioTime(sampleTime: 44100, atRate: 41000)

        let event = AutomationEvent(targetValue: 880, startTime: 0, rampDuration: 1.0)
        oscillator.$frequency.automate(events: [event], startTime: startTime)

        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testAutomationAfterDelayedConnection() {
        let engine = AudioEngine()
        let osc = Oscillator(waveform: Table(.triangle))
        let osc2 = Oscillator(waveform: Table(.triangle))
        let mixer = Mixer()
        let events = [AutomationEvent(targetValue: 1320, startTime: 0.0, rampDuration: 0.5)]
        engine.output = mixer
        mixer.addInput(osc)
        let audio = engine.startTest(totalDuration: 2.0)
        osc.play()
        osc.$frequency.automate(events: events)
        audio.append(engine.render(duration: 1.0))
        mixer.removeInput(osc)
        mixer.addInput(osc2)
        osc2.play()
        osc2.$frequency.automate(events: events)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDelayedAutomation() throws {
        let engine = AudioEngine()
        let osc = Oscillator(waveform: Table(.triangle))
        engine.output = osc
        osc.amplitude = 0.2
        osc.start()
        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))
        let events = [AutomationEvent(targetValue: 1320, startTime: 0, rampDuration: 0.1),
                      AutomationEvent(targetValue: 660, startTime: 0.1, rampDuration: 0.1),
                      AutomationEvent(targetValue: 1100, startTime: 0.2, rampDuration: 0.1),
                      AutomationEvent(targetValue: 770, startTime: 0.3, rampDuration: 0.1),
                      AutomationEvent(targetValue: 880, startTime: 0.4, rampDuration: 0.1)]
        osc.$frequency.automate(events: events)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
