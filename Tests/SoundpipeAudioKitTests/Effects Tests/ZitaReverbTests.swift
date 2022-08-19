// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import SoundpipeAudioKit
import XCTest

class ZitaReverbTests: XCTestCase {
    func testResetZitaReverb() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table([1, 1]))
        let reverb = ZitaReverb(input)
        engine.output = reverb
        input.start()
        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 1.0))
        XCTAssertEqual(audio.toFloatChannelData()?[0].count, 44100)

        reverb.reset()
        audio.append(engine.render(duration: 1.0))

        XCTAssertEqual(audio.toFloatChannelData()?[0].count, 88200)
    }
}
