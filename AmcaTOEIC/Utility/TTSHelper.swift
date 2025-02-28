//
//  TTSHelper.swift
//  AmcaTOEIC
//
//  Created by Anto-Yang on 2/27/25.
//
import AVFoundation

class TTSHelper: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = TTSHelper()
    private let synthesizer = AVSpeechSynthesizer()
    private var repeatCount = 0
    private var targetString: String = ""
    private let maxRepeat = 1
    private var completionHandler: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
        prepare()
    }
    
    func prepare() {
        do {
            // 앱 시작 시 한 번만 설정
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
        } catch {
            shLog("Audio session setup error: \(error)")
        }
    }
    
    internal func play(_ string: String, completion: (() -> Void)? = nil) {
        // 기존 재생 중이라면 중단하고 초기화
        if synthesizer.isSpeaking {
            shLog("TTS 기존 음성 중지")
            stop()
        }
        
        shLog("TTS 음성 읽을 문장: \(string)")
        
        repeatCount = 0
        targetString = string
        completionHandler = completion
        speak()
    }
    
    private func speak() {
        guard repeatCount < maxRepeat else { return }
        
        let utterance = AVSpeechUtterance(string: targetString)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 0.8
        utterance.preUtteranceDelay = 0.0

        do {
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            shLog("Audio session setup error: \(error)")
        }
        
        synthesizer.speak(utterance)
        
    }
    
    internal func stop() {
        if synthesizer.isSpeaking {
            shLog("TTS 음성 강제 중지")
            synthesizer.stopSpeaking(at: .immediate)
        }
        completionHandler?()
        completionHandler = nil
    }
    
    // 음성이 끝날 때 호출됨
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        shLog("TTS 음성 완료")
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [])
        } catch {
            shLog("Audio session setup error: \(error)")
        }
        
        completionHandler?()
        completionHandler = nil
    }
}
