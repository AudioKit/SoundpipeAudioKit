// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import SoundpipeAudioKit
import XCTest

class EnsembleTests: XCTestCase {
    
    func testMajorChord() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        // Create a C major chord: C, E, G (0, 4, 7 semitones)
        let ensemble = Ensemble(input,
                                shifts:[0, 4, 7], pans: [-1, 1],
                                dryWetMix: 1.0)
        ensemble.$shift2.ramp(to: 12, duration: 5.0)
        ensemble.$pan2.ramp(to: -1, duration: 5.0)
        engine.output = ensemble
        let audio = engine.startTest(totalDuration: 5.0)
        input.play()
        audio.append(engine.render(duration: 5.0))
        audio.audition()
    }
}
