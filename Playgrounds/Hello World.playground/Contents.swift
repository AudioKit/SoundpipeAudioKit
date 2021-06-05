import AudioKit
import SoundpipeAudioKit
import Foundation

let osc = Oscillator(amplitude: 0.3)

let engine = AudioEngine()
engine.output = osc
osc.play()

try! engine.start()

while true {
    osc.frequency = Float.random(in: 200...800)
    sleep(1)
}
