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
    "-[BalancerTests testDefault]": "26e2c62078ee266c120677b7386ab292",
    "-[ConvolutionTests testConvolution]": "d585f94eba7aedafd7987c68af78ff75",
    "-[ConvolutionTests testStereoConvolution]": "4b7904aebc448fc6d5fbcdefba320b2a",
    "-[DiodeLadderFilterTests testBypass]": "2aeb94f662f38dde83d9bb70c5ceeac0",
    "-[DiodeLadderFilterTests testParameterRamping]": "b82608eee1e82b421d0ecc3425764c1e",
    "-[DiodeLadderFilterTests testReset]": "72e56cdab82e8f23ea0473bf261861ec",
    "-[DiodeLadderFilterTests testSampleRateChange]": "bf552ba8542b20f9c229c0d510cd443c",
    "-[DynamicOscillatorTests testAmpitude]": "86497903abc5f53ef15fecf5660709bb",
    "-[DynamicOscillatorTests testDefault]": "7a3dc1fdc7f7c4d113ba9d1119143e67",
    "-[DynamicOscillatorTests testDetuningMultiplier]": "b9caf0d0e39aa5bf6073f861ff7cdd23",
    "-[DynamicOscillatorTests testDetuningOffset]": "ee8fc07672ed022a4c86146b18a38aca",
    "-[DynamicOscillatorTests testFrequency]": "33fc3ddee3e17226ddfc976f080b7e00",
    "-[DynamicOscillatorTests testParametersSetAfterInit]": "7ae6c2133daa0b06f24c29d979424e14",
    "-[DynamicOscillatorTests testParameters]": "7ae6c2133daa0b06f24c29d979424e14",
    "-[DynamicOscillatorTests testRamping]": "5336499be4b3eb5284e1d929c612341b",
    "-[DynamicOscillatorTests testNewAutomationFrequency]": "5c8c218d2c21e8c436493bb09a80a47a",
    "-[DynamicOscillatorTests testNewAutomationAmplitude]": "b8e89a1380f3159979b37d3f8dff441e",
    "-[DynamicOscillatorTests testNewAutomationMultiple]": "3b499b52ae246e9c0403bc4f79b0e050",
    "-[DynamicOscillatorTests testNewAutomationDelayed]": "805e616c4ee5971d698c79982d502227",
    "-[DynamicOscillatorTests testSetWavetable]": "b8a90867e0736e04de7dd6e4794ec494",
    "-[DynamicOscillatorTests testGetWavetableValues]": "33fc3ddee3e17226ddfc976f080b7e00",
    "-[DynamicOscillatorTests testWavetableUpdateHandler]": "33fc3ddee3e17226ddfc976f080b7e00",
    "-[FlatFrequencyResponseReverbTests testLoopDuration]": "b52e5fe292fae790c8ebf997347774a3",
    "-[MetalBarTests testDefault]": "581849d96fa6f62daeba2534c2efc17c",
    "-[OscillatorAutomationTests testNewAutomationAmplitude]": "de84a09903129c3c22cc035cfd53ff05",
    "-[OscillatorAutomationTests testNewAutomationDelayed]": "170f682ea6ad60e6a94ad48aba159efe",
    "-[OscillatorAutomationTests testNewAutomationFrequency]": "5c8c218d2c21e8c436493bb09a80a47a",
    "-[OscillatorAutomationTests testNewAutomationMultiple]": "c1840e8045b8d976ca0aaddb984da4c5",
    "-[OscillatorAutomationTests testAutomationAfterDelayedConnection]": "f5f2cf536578d5a037c88d2cd458eb10",
    "-[OscillatorAutomationTests testDelayedAutomation]": "b4c68d2afd4fdbb5074b7ddc655ea5c6",
    "-[PhaseLockedVocoderTests testDefault]": "d3522d2e9cad9467740cbcb3624887f2",
    "-[PitchTapTests testBasic]": "db6a903846a19d9e06066391308ee7ff",
    "-[PluckedStringTests testDefault]": "9e2d3aa3b50fa53a43b798901f0cb0e5",
]
