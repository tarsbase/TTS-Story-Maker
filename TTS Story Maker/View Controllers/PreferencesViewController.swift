//
//  PreferencesViewController.swift
//  TTS Story Maker
//
//  Created by Emily Blackwell on 05/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

import Cocoa

let KTPAllowsEffects = "allowsPortraitEffects"
let KTPDefaultVoice = "defaultVoice"
let KTPEditorAutoCorrectSuggest = "usesAutoCorrect"
let KTPEditorSyntaxHighlighting = "usesSyntaxHighlighting"

class PreferencesViewController: NSViewController {
	
	@IBOutlet weak var defaultVoiceCombobox: NSComboBox!
	@IBOutlet weak var editorCheckingCB: NSButton!
	@IBOutlet weak var editorSyntaxCB: NSButton!
	@IBOutlet weak var allowsEffectsCB: NSButton!
	
	var tts: NSSpeechSynthesizer!
	let preferencesController = PreferencesController.shared

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let defaults = preferencesController.defaults
		
		// set up our "default voice" combo box
		defaultVoiceCombobox.removeAllItems()
		
		for voice in NSSpeechSynthesizer.availableVoices {
			defaultVoiceCombobox.addItem(withObjectValue: voice.rawValue)
		}
		
		// set default values
		editorCheckingCB?.state = defaults.value(forKey: KTPEditorAutoCorrectSuggest) as! Bool ? .on : .off
		editorSyntaxCB?.state = defaults.value(forKey: KTPEditorSyntaxHighlighting) as! Bool ? .on : .off
		allowsEffectsCB?.state = defaults.value(forKey: KTPAllowsEffects) as! Bool ? .on : .off
		defaultVoiceCombobox?.stringValue = defaults.value(forKey: KTPDefaultVoice) as! String
		
		// set up our preview TTS synthesizer
		tts = NSSpeechSynthesizer()
    }
	
	private func setVoice() {
		if !tts.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: defaultVoiceCombobox.stringValue)) {
			tts.setVoice(NSSpeechSynthesizer.defaultVoice)
			defaultVoiceCombobox.stringValue = NSSpeechSynthesizer.defaultVoice.rawValue
		}
	}
	
	// MARK: Actions
	@IBAction func previewVoice(sender: AnyObject) {
		if tts.isSpeaking {
			tts.stopSpeaking()
		}
		
		let text = "This is what the default voice sounds like."
		
		// if the user tries to enter a random (or missing) voice identifier
		// then revert back to the system default
		
		setVoice()
		tts.startSpeaking(text)
	}
	
	@IBAction func checkboxToggled(sender: NSButton) {
		let tag = sender.tag
		let checked = sender.state == .on
		
		// portrait effects
		switch tag {
		case 0:
			preferencesController.set(value: checked, for: KTPAllowsEffects)
			break
			
		case 1:
			preferencesController.set(value: checked, for: KTPEditorAutoCorrectSuggest)
			break
			
		case 2:
			preferencesController.set(value: checked, for: KTPEditorSyntaxHighlighting)
			break
			
		default:
			break
		}
	}
	
	@IBAction func setDefaultVoice(sender: NSComboBox) {
		setVoice()
		preferencesController.set(value: sender.stringValue, for: KTPDefaultVoice)
	}
	
}
