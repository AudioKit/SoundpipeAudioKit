// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import SoundpipeAudioKit
import XCTest

class PitchShifterTests: XCTestCase {
    func testResetPitchShifter() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table([1, 1]))
        let shifter = PitchShifter(input)
        engine.output = shifter
        input.start()
        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 1.0))
        XCTAssertEqual(audio.toFloatChannelData()?[0].count, 44100)

        shifter.reset()
        audio.append(engine.render(duration: 1.0))

        XCTAssertEqual(audio.toFloatChannelData()?[0].count, 88200)
    }
}
