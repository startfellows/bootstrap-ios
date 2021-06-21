//
//  Created by Anton Spivak.
//  

import Foundation
import AVFoundation
import Accelerate
import CoreAudio
import Speech

public class Microphone {
    
    public struct Meter {
        
        public let time: TimeInterval
        public let rms: Float
        public let ftt: [Float]
    }
    
    private let audioEngine: AVAudioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile? = nil
    private let processor: Processor = Processor()
    private var start: Double?
    
    private let levels: Int = 5
    private let fftSetup = vDSP_DFT_zop_CreateSetup(nil, 1024, vDSP_DFT_Direction.FORWARD)!
    
    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: Any?
    private var recognizedText: String?
    
    public var effect: Effect? = nil
    public var meters: [Meter] = []
    
    public init() {}
    
    public func record(into _fileURL: URL) throws {
        recognizedText = nil
        
        let fileURL = _fileURL.appendingPathExtension(UUID().uuidString)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: _fileURL.absoluteString))

        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        if let request = recognitionRequest {
            recognitionTask = speechRecognizer?.recognitionTask(with:request, resultHandler: { [weak self] (value, error) in
                self?.recognizedText = value?.bestTranscription.formattedString
            })
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: { [weak self] (buffer: AVAudioPCMBuffer, time: AVAudioTime) in
            self?.processAudioBuffer(buffer, time)
            self?.recognitionRequest?.append(buffer)
        })

        let mainMixerNode = audioEngine.mainMixerNode
        mainMixerNode.removeTap(onBus: 0)

        let outputFormat = mainMixerNode.outputFormat(forBus: 0)
        audioFile = try AVAudioFile(forWriting: fileURL, settings: outputFormat.settings, commonFormat: .pcmFormatFloat32, interleaved: false)
        mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: outputFormat, block: { [weak self] (buffer: AVAudioPCMBuffer, time: AVAudioTime) in
            try? self?.audioFile?.write(from: buffer)
        })

        audioEngine.connect(audioEngine.inputNode, to: audioEngine.mainMixerNode, format: nil)

        audioEngine.prepare()
        try audioEngine.start()
    }
    
    @discardableResult
    public func stop(process: Bool) throws -> (URL, String?) {
        recognitionTask = nil
        recognitionRequest = nil
        
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)

        let mainMixerNode = audioEngine.mainMixerNode
        mainMixerNode.removeTap(onBus: 0)

        audioEngine.stop()
        audioEngine.reset()

        let tmpURL = audioFile!.url
        let outputURL = tmpURL.deletingPathExtension()

        if process {
            try processor.process(inputURL: tmpURL, outputURL: outputURL, with: effect)
        }

        start = nil
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: tmpURL.absoluteString))

        return (outputURL, recognizedText)
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer, _ time: AVAudioTime) {
        guard let channelData = buffer.floatChannelData?[0]
        else {
            return
        }
        
        if start == nil {
            start = AVAudioTime.seconds(forHostTime: time.hostTime)
        }
        
        let start = start!
        let current = AVAudioTime.seconds(forHostTime: time.hostTime)
        let time = current - start
        
        let meter = Meter(
            time: time,
            rms: rms(data: channelData, frameLength: UInt(buffer.frameLength)),
            ftt: fft(data: channelData, setup: fftSetup)
        )
        
        DispatchQueue.main.async(execute: {
            if self.meters.count > 42 {
                self.meters.removeFirst()
            }
            self.meters.append(meter)
        })
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
