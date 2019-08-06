//
//  PreferencesController.swift
//  TTS Story Maker
//
//  Created by Emily Blackwell on 05/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

import Cocoa

protocol PreferencesDelegate {
	func settingUpdated(key: String, value: Any?)
}

struct DelegateObject {
	let delegate: PreferencesDelegate
	let key: String
}

class PreferencesController: NSObject {
	static let shared = PreferencesController()
	private var uniqueIDs: [String: Int] = [:]
	
	let defaults = UserDefaults.standard
	private var delegates: [DelegateObject] = []
	
	override init() {
		super.init()
		
		let defaults = UserDefaults.standard
		
		// set default preferences values
		if defaults.value(forKey: KTPDefaultVoice) == nil {
			defaults.set(NSSpeechSynthesizer.defaultVoice.rawValue, forKey: KTPDefaultVoice)
			defaults.set(true, forKey: KTPAllowsEffects)
			defaults.set(true, forKey: KTPEditorSyntaxHighlighting)
			defaults.set(true, forKey: KTPEditorAutoCorrectSuggest)
		}
	}
	
	func uniqueKey(name: String) -> String {
		guard let uniqueID = uniqueIDs[name] else {
			uniqueIDs[name] = Int.min
			return uniqueKey(name: name)
		}
		
		let key = "name-\(uniqueID)"
		uniqueIDs[name] = uniqueID + 1
		
		return key
	}
	
	func set(value: Any?, for key: String) {
		defaults.set(value, forKey: key)
		
		// send our "updated" message to our delegates (so they can apply it immediately)
		for object in delegates {
			object.delegate.settingUpdated(key: key, value: value)
		}
	}
	
	func add(delegate: PreferencesDelegate, with key: String) {
		let object = DelegateObject(delegate: delegate, key: key)
		delegates.append(object)
	}
	
	func delete(delegate key: String) {
		for (i, object) in delegates.enumerated() {
			if object.key == key {
				delegates.remove(at: i)
				break
			}
		}
	}
}
