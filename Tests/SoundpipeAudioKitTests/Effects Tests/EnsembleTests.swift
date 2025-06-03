// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import SoundpipeAudioKit
import XCTest

class EnsembleTests: XCTestCase {
    
    func testMajorChord() {
        let engine = AudioEngine()
        let input = Oscillator()
        // Create a C major chord: C, E, G (0, 4, 7 semitones)
        let ensemble = Ensemble(input,
                                shifts:[0, 7],
                                dryWetMix: 1.0)
        ensemble.$shift2.ramp(to: 7, duration: 10.0)
        engine.output = ensemble
        input.start()
        let audio = engine.startTest(totalDuration: 10.0)
        audio.append(engine.render(duration: 10.0))
        audio.audition()
    }
}
