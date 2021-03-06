//
//  Created by Anton Spivak.
//  

import Foundation
import AVFoundation
import Speech

public class Session {
    
    let engine: AVAudioEngine
    let file: AVAudioFile
    let time: TimeInterval
    
    let authorization: SFSpeechRecognizerAuthorizationStatus = SFSpeechRecognizer.authorizationStatus()
    var recognizer: SFSpeechRecognizer? = nil
    var request: SFSpeechAudioBufferRecognitionRequest? = nil
    var task: SFSpeechRecognitionTask? = nil
    
    let processor: Processor
    
    public var meterings: [Metering] = []
    public var format: Format = .caf
    public var text: String = ""
    
    init(engine: AVAudioEngine, fileURL: URL, format: AVAudioFormat, type: Format) throws {
        self.format = type
        self.engine = engine
        self.file = try AVAudioFile(forWriting: fileURL, settings: format.settings, commonFormat: .pcmFormatFloat32, interleaved: false)
        self.time = -1
        
        if authorization == .authorized {
            guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
            else {
                throw Error.recognition
            }
            
            self.recognizer = recognizer
            self.request = SFSpeechAudioBufferRecognitionRequest()
            self.request?.shouldReportPartialResults = true
        }
        
        self.processor = Processor()
    }
    
    func accept(_ buffer: AVAudioPCMBuffer, with time: AVAudioTime) {
        if let meters = processor.process(buffer, time) {
            DispatchQueue.main.async(execute: {
                self.meterings.append(meters)
            })
        }
        
        if let request = request, task == nil {
            task = recognizer?.recognitionTask(with: request, resultHandler: { [weak self] (value, error) in
                self?.text = value?.bestTranscription.formattedString ?? ""
            })
        }
        
        request?.append(buffer)
    
        do {
            try file.write(from: buffer)
        } catch {
            print(error)
        }
    }
    
    func stop() {
        task?.finish()
        task = nil
        
        engine.stop()
        engine.reset()
    }
}
