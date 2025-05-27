// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import SoundpipeAudioKit
import XCTest
import AVFoundation
import Tonic

class PitchCorrectTests: XCTestCase {
    func testPitchCorrect() {
        let engine = AudioEngine()
        
        // Create oscillator that will sweep from 110 to 880 Hz
        let oscillator = Oscillator(waveform: Table(.sine))
        oscillator.frequency = 220
        oscillator.amplitude = 0.5
        
        // Create pitch correction
        let pitchCorrect = PitchCorrect(oscillator, key: .A, speed: 1.0, amount: 1.0)
        
        engine.output = pitchCorrect
        
        let audio = engine.startTest(totalDuration: 5.0)
        
        // Start the oscillator
        oscillator.play()
        
        // Ramp frequency from 110 to 880 over 10 seconds
        oscillator.$frequency.ramp(to: 440, duration: 5.0)
        
//        pitchCorrect.setScaleFrequencies([220,245,350,395])
//        pitchCorrect.setValidNotes(root: .C, scale: .major)
//        pitchCorrect.setValidNotes(.C, .Dsharp, .E)

        
        audio.append(engine.render(duration: 5.0))
        
        testMD5(audio)
        audio.audition()
    }
}
