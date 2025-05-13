import AVFoundation
import XCTest

extension XCTestCase {
    func testMD5(_ buffer: AVAudioPCMBuffer) {
        let localMD5 = buffer.md5
        let name = description
        XCTAssert(validatedMD5s[name] == buffer.md5, "\nFAILEDMD5 \"\(name)\": \"\(localMD5)\",")
    }
}

let validatedMD5s: [String: String] = [
    "-[AmplitudeEnvelopeTests testAttack]": "d854eb2e2033f57db8eaece7352158a1",
    "-[AmplitudeEnvelopeTests testDecay]": "049f077cfac89eb544bba6386ef3cd41",
    "-[AmplitudeEnvelopeTests testDefault]": "2a0becc83d69bbf8635ab21c2e53bbe3",
    "-[AmplitudeEnvelopeTests testDoubleStop]": "584a2da667f8e83f085addf29e8b10bf",
    "-[AmplitudeEnvelopeTests testParameters]": "d13574ced5796c3dcf56ce14a231b9a7",
    "-[AmplitudeEnvelopeTests testRelease]": "584a2da667f8e83f085addf29e8b10bf",
    "-[AmplitudeEnvelopeTests testSustain]": "eab230014d499b2d8c82781d2b645cdc",
    "-[BalancerTests testDefault]": "4e21fb4802373b74ba0daad7fff064e5",
    "-[ConvolutionTests testConvolution]": "5dd3ed9fbe484642d61ecac16b56f99d",
    "-[ConvolutionTests testStereoConvolution]": "bb97b164e0652b763f260928f0743bda",
    "-[DiodeLadderFilterTests testBypass]": "71ee08d0edeeb93c405a59a214ec7be0",
    "-[DiodeLadderFilterTests testParameterRamping]": "7e66426f407b1bcc9d7eacfffb16f05d",
    "-[DiodeLadderFilterTests testReset]": "75f9d75e4478e47dbbac926138e99bff",
    "-[DiodeLadderFilterTests testSampleRateChange]": "ec97ea2b614f085202714c04f5dc474b",
    "-[DynamicOscillatorTests testAmpitude]": "86497903abc5f53ef15fecf5660709bb",
    "-[DynamicOscillatorTests testDefault]": "7a3dc1fdc7f7c4d113ba9d1119143e67",
    "-[DynamicOscillatorTests testDetuningMultiplier]": "b9caf0d0e39aa5bf6073f861ff7cdd23",
    "-[DynamicOscillatorTests testDetuningOffset]": "ee8fc07672ed022a4c86146b18a38aca",
    "-[DynamicOscillatorTests testFrequency]": "33fc3ddee3e17226ddfc976f080b7e00",
    "-[DynamicOscillatorTests testParametersSetAfterInit]": "7ae6c2133daa0b06f24c29d979424e14",
    "-[DynamicOscillatorTests testParameters]": "7ae6c2133daa0b06f24c29d979424e14",
    "-[DynamicOscillatorTests testRamping]": "5336499be4b3eb5284e1d929c612341b",
    "-[DynamicOscillatorTests testNewAutomationFrequency]": "d7e6f65d67b93feb3172d84dae26b890",
    "-[DynamicOscillatorTests testNewAutomationAmplitude]": "f1c1ed472e0536b4fc8a3b2b7ea46a47",
    "-[DynamicOscillatorTests testNewAutomationMultiple]": "2ffe3cacba00011f36e7f10622c92d80",
    "-[DynamicOscillatorTests testNewAutomationDelayed]": "1e6c97ed856999116f1a65dabe8c8983",
    "-[DynamicOscillatorTests testSetWavetable]": "b8a90867e0736e04de7dd6e4794ec494",
    "-[DynamicOscillatorTests testGetWavetableValues]": "33fc3ddee3e17226ddfc976f080b7e00",
    "-[DynamicOscillatorTests testWavetableUpdateHandler]": "33fc3ddee3e17226ddfc976f080b7e00",
    "-[FlatFrequencyResponseReverbTests testLoopDuration]": "b54df1d5323ceb1fa40cca3617d37064",
    "-[MetalBarTests testDefault]": "be746ce6c1f51d3ec2361f5ae50785af",
    "-[OscillatorAutomationTests testNewAutomationAmplitude]": "f1c1ed472e0536b4fc8a3b2b7ea46a47",
    "-[OscillatorAutomationTests testNewAutomationDelayed]": "9816610a225eaf1a1313b0b897ba52d0",
    "-[OscillatorAutomationTests testNewAutomationFrequency]": "d7e6f65d67b93feb3172d84dae26b890",
    "-[OscillatorAutomationTests testNewAutomationMultiple]": "2ffe3cacba00011f36e7f10622c92d80",
    "-[OscillatorAutomationTests testAutomationAfterDelayedConnection]": "93d96731b7ca3dc9bf1e4209bd0b65ec",
    "-[OscillatorAutomationTests testDelayedAutomation]": "640265895a27587289d65a29ce129804",
    "-[PhaseLockedVocoderTests testDefault]": "eb9fe2d8ee2e3b3d6527a4e139c2686e",
    "-[PitchTapTests testBasic]": "5b6ae6252df77df298996a7367a00a9e",
    "-[PluckedStringTests testDefault]": "3f13907e6e916b7a4bf6046a4cbf0764",
    "-[TalkboxTests testTalkbox]": "316ef6638793f5fb6ec43fae1919ccff",
    "-[VocoderTests testVocoder]": "1e084a4d0399923b923ff6a07dc8a320",
]
