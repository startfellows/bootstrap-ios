//
//  Created by Anton Spivak.
//  

import Foundation
import AVFoundation
import Accelerate

internal class Processor {
    
    private let levels: Int = 5
    private let fftSetup = vDSP_DFT_zop_CreateSetup(nil, 1024, vDSP_DFT_Direction.FORWARD)!
    private var start: TimeInterval = -1
    
    func process(_ buffer: AVAudioPCMBuffer, _ time: AVAudioTime) -> Metering? {
        guard let channelData = buffer.floatChannelData?[0]
        else {
            return nil
        }
        
        if start == -1 {
            start = AVAudioTime.seconds(forHostTime: time.hostTime)
        }
        
        let current = AVAudioTime.seconds(forHostTime: time.hostTime)
        let time = current - start
        
        let metering = Metering(
            time: time,
            rms: rms(data: channelData, frameLength: UInt(buffer.frameLength)),
            ftt: fft(data: channelData, setup: fftSetup)
        )
        
        return metering
    }
    
    private func rms(data: UnsafeMutablePointer<Float>, frameLength: UInt) -> Float {
        var val : Float = 0
        vDSP_measqv(data, 1, &val, frameLength)

        var db = 10 * log10f(val)
        
        // inverse dB to +ve range where 0 (silent) -> 160 (loudest)
        db = 160 + db;
        
        // Only take into account range from 120 -> 160, so FSR = 40
        db = db - 120

        let divider: Float = 40
        var adjustedValue =  db / divider

        // cutoff
        if (adjustedValue < 0) {
            adjustedValue = 0
        } else if (adjustedValue > 1) {
            adjustedValue = 1
        }
        
        return adjustedValue
    }
        
    private func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float] {
        let count = 1024
        
        var realIn = [Float](repeating: 0, count: count)
        var imagIn = [Float](repeating: 0, count: count)
        
        let realOut = UnsafeMutablePointer<Float>.allocate(capacity: count)
        let imagOut = UnsafeMutablePointer<Float>.allocate(capacity: count)
        
        // fill in real input part with audio samples
        for i in 0..<count {
            realIn[i] = data[i]
        }

        vDSP_DFT_Execute(setup, &realIn, &imagIn, realOut, imagOut)
        
        var complex = DSPSplitComplex(realp: realOut, imagp: imagOut)
        
        var magnitudes = [Float](repeating: 0, count: levels)
        vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(levels))
        
        // normalize
        var normalizedMagnitudes = [Float](repeating: 0.0, count: levels)
        var scalingFactor: Float = 0.05
        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, UInt(levels))
        
        realOut.deallocate()
        imagOut.deallocate()
        
        return normalizedMagnitudes
    }
}
