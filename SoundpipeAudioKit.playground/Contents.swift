//: A simple playground to test SoundpipeAudioKit makes sounds
import AudioKit
import Foundation
import SoundpipeAudioKit

let osc = Oscillator(amplitude: 0.2)

let engine = AudioEngine()
engine.output = osc

try! engine.start()

while true {
    osc.frequency = Float.random(in: 200 ... 800)
    osc.play()
    sleep(1)
    osc.stop()
    sleep(1)
}
