//
//  PlaybackViewController.swift
//  TTS Story Maker
//
//  Created by Emily Blackwell on 04/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

import Cocoa

protocol PlaybackDelegate {
	func positionUpdated(current: Int)
}

class PlaybackViewController: NSViewController {
	
	weak var story: ISStory!
	
	@IBOutlet weak var portraitView: NSImageView!
	@IBOutlet weak var portraitBG: NSImageView!
	@IBOutlet weak var speakerLabel: NSTextField!
	@IBOutlet weak var dialogueLabel: NSTextField!
	@IBOutlet weak var progressIndicator: NSProgressIndicator!
	@IBOutlet weak var tipLabel: NSTextField!
	
	var tts: NSSpeechSynthesizer!
	var delegate: PlaybackDelegate?
	
	private var defaultVoice: String = ""
	private var portraitEffects: [Any]? = []

    override func viewDidLoad() {
        super.viewDidLoad()
		
		tts = NSSpeechSynthesizer()
		tts.delegate = self
		
		tipLabel?.wantsLayer = true
		
		PreferencesController.shared.add(delegate: self, with: "playWindow")
    }
	
	override func viewDidAppear() {
		next(sender: self)
		portraitBG?.layer?.backgroundColor = .black
		portraitEffects = portraitBG?.layer?.filters
		
		// hide our tip label
		Timer.scheduledTimer(timeInterval: 2.0,
							 target: self,
							 selector: #selector(hideTipLabel),
							 userInfo: nil,
							 repeats: false)
		
		// apply user preferences
		let defaults = UserDefaults.standard
		let allowsEffects = defaults.bool(forKey: KTPAllowsEffects)
		
		togglePortraitEffects(enabled: allowsEffects)
		defaultVoice = defaults.string(forKey: KTPDefaultVoice)!
	}
	
	override func viewWillDisappear() {
		// stop any remaining dialogue
		if tts.isSpeaking {
			tts.stopSpeaking(at: .wordBoundary)
		}
		
		PreferencesController.shared.delete(delegate: "playWindow")
	}
	
	// MARK: Actions
	func updateUI(scene: ISScene?) {
		guard let scene = scene else {
			return
		}
		
		let photo = self.story.photo(for: scene.speaker)
		let voice = self.story.voice(for: scene.speaker) ?? NSSpeechSynthesizer.VoiceName(rawValue: self.defaultVoice)
		
		// update our UI
		self.progressIndicator?.doubleValue = self.story.progress()
		
		self.portraitView?.image = photo
		self.portraitBG?.image = photo
		
		self.speakerLabel?.stringValue = scene.speaker
		self.dialogueLabel?.stringValue = scene.dialogue
		
		// prepare our synthesizer
		if self.tts.isSpeaking {
			self.tts.stopSpeaking(at: .wordBoundary)
		}
		
		self.tts.setVoice(voice)
		self.tts.startSpeaking(scene.dialogue)
	}
	
	func seek(position: Int) {
		let scene = story.seekScene(at: position)
		updateUI(scene: scene)
	}
	
	@IBAction func next(sender: AnyObject) {
		let scene = story.nextScene()
		updateUI(scene: scene)
		
		delegate?.positionUpdated(current: story.current)
	}
	
	@IBAction func previous(sender: AnyObject) {
		let scene = story.previousScene()
		updateUI(scene: scene)
		
		delegate?.positionUpdated(current: story.current)
	}
}

extension PlaybackViewController: NSSpeechSynthesizerDelegate {
	// automatically go to the next scene once the voice-over finishes their dialogue
	func speechSynthesizer(_ sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool) {
		if finishedSpeaking {
			next(sender: self)
		}
	}
}

extension PlaybackViewController: CAAnimationDelegate {
	@objc func hideTipLabel() {
		let animation = CABasicAnimation(keyPath: "opacity")
		
		animation.fromValue = 1.0
		animation.toValue = 0.0
		animation.duration = 1.0
		animation.autoreverses = false
		animation.delegate = self
		
		tipLabel?.layer?.add(animation, forKey: "hideAnimation")
	}
	
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		tipLabel?.isHidden = true
	}
}

extension PlaybackViewController: PreferencesDelegate {
	func togglePortraitEffects(enabled: Bool) {
		if enabled {
			portraitBG?.layer?.filters = portraitEffects
			portraitBG?.layer?.opacity = 1
		} else {
			portraitBG?.layer?.filters?.removeAll()
			portraitBG?.layer?.opacity = 0.15
		}
	}
	
	func settingUpdated(key: String, value: Any?) {
		if key == KTPAllowsEffects {
			guard let allowsEffects = value as? Bool else {
				return
			}
			
			togglePortraitEffects(enabled: allowsEffects)
		}
		
		if key == KTPDefaultVoice {
			guard let defaultVoice = value as? String else {
				return
			}
			
			self.defaultVoice = defaultVoice
		}
	}
}
