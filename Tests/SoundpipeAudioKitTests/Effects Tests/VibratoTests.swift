// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import SoundpipeAudioKit
import XCTest

class VibratoTests: XCTestCase {
    func testVibrato() {
        let engine = AudioEngine()
        let input = Oscillator()
        let vibrato = Vibrato(input)
        engine.output = vibrato
        
        input.start()
        vibrato.speed = 10
        vibrato.depth = 3
        
        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 2.0))
        
        testMD5(audio)
    }

    func testParameterSweep() {
        let engine = AudioEngine()
        let input = Oscillator()
        let vibrato = Vibrato(input)
        engine.output = vibrato
        
        input.start()
        
        let audio = engine.startTest(totalDuration: 5.0)
        
        // Sweep speed from 0 to 10 Hz
        vibrato.$speed.ramp(to: 20, duration: 5)
        
        // Then sweep depth from 0 to 5 semitones
        vibrato.$depth.ramp(to: 24, duration: 5)
        
        audio.append(engine.render(duration: 5.0))
        
        testMD5(audio)
    }
}
