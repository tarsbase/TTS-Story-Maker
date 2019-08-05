//
//  ISStory.swift
//  Story Framework
//
//  Created by Emily Blackwell on 04/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

#if os(macOS)

import Cocoa

#elseif os(iOS)

import UIKit
import AVFoundation

#endif

class ISScene: NSObject {
	var speaker: String
	var dialogue: String
	var choices: [ISChoice] = []
	
	init(speaker: String, dialogue: String) {
		self.speaker = speaker
		self.dialogue = dialogue
	}
}

class ISChoice: NSObject {
	var label: String
	var scenes: [ISScene] = []
	
	init(label: String) {
		self.label = label
	}
}

class ISStory: NSObject {
	var title: String?
	var author: String?
	var scenes: [ISScene] = []
	var current = 0
	
	#if os(macOS)
	
	var characterVoices: [String: NSSpeechSynthesizer.VoiceName] = [:]
	var characterPhotos: [String: NSImage] = [:]
	
	#elseif os(iOS)
	
	var characterVoices: [String: AVSpeechSynthesisVoice] = [:]
	var characterPhotos: [String: UIImage] = [:]
	
	#endif
	
	override init() {
		super.init()
	}
	
	init(string: String) {
		super.init()
		readFrom(string: string)
	}
	
	init(file: String) {
		super.init()
		readFrom(file: file)
	}
	
	func reset() {
		characterPhotos.removeAll()
		characterVoices.removeAll()
		scenes.removeAll()
		
		current = 0
	}
	
	private func key(from string: String) -> String {
		return string.replacingOccurrences(of: ":", with: "")
	}
	
	func seekScene(at: Int) -> ISScene? {
		guard at >= 0 && at < scenes.count else {
			return nil
		}
		
		current = at
		return scenes[at]
	}
	
	func nextScene() -> ISScene? {
		guard current < scenes.count else {
			return nil
		}
		
		let scene = scenes[current]
		current += 1
		
		return scene
	}
	
	func previousScene() -> ISScene? {
		guard current > 0 else {
			return nil
		}
		
		let scene = scenes[current]
		current -= 1
		
		return scene
	}
	
	func readFrom(string: String) {
		reset()
		
		// compile our regexp patterns
		guard let speakerPattern = try? NSRegularExpression(pattern: "^([a-z\' ]+)\\: *$", options: .caseInsensitive) else {
			fatalError("Unable to compile regular expression patern!")
		}
		
		var lastSpeaker: String?
		
		// get the lines from our script (minus the comments)
		let lines = string.split(separator: "\n").filter { line in
			return !line.starts(with: "#")
		}
		
		for line in lines {
			let line = String(line)
			let matches = line.matches(for: speakerPattern)
			let type = matches.count > 0 ? "Speaker" : "Dialogue"
			
			if type == "Speaker" {
				lastSpeaker = line
				
				// remove trailing whitespace
				var end = lastSpeaker!.count
				
				for i in (0 ..< end).reversed() {
					if lastSpeaker![lastSpeaker!.index(i)] != " " {
						end = i
						break
					}
				}
				
				let startIndex = lastSpeaker!.index(0)
				let endIndex = lastSpeaker!.index(end)
				let newLS = lastSpeaker![startIndex ..< endIndex]
				lastSpeaker = String(newLS)
			} else {
				guard let speaker = lastSpeaker else {
					continue
				}
				
				let scene = ISScene(speaker: speaker, dialogue: line)
				scenes.append(scene)
			}
		}
	}
	
	func readFrom(file: String) {
		guard let contents = try? String(contentsOf: URL(fileURLWithPath: file)) else {
			return
		}
		
		readFrom(string: contents)
	}
	
	func progress() -> Double {
		return Double(current) / Double(scenes.count)
	}
	
	#if os(macOS)
	
	func addCharacterVoice(_ voice: NSSpeechSynthesizer.VoiceName, for name: String) {
		characterVoices[name] = voice
	}
	
	func addCharacterVoice(_ voice: String, for name: String) {
		let identifier = "com.apple.speech.synthesis.voice.\(voice)"
		characterVoices[name] = NSSpeechSynthesizer.VoiceName(rawValue: identifier)
	}
	
	func voice(for name: String) -> NSSpeechSynthesizer.VoiceName? {
		let nkey = key(from: name)
		
		guard let voice = characterVoices[nkey] else {
			return nil
		}
		
		return voice
	}
	
	func addCharacterPhoto(_ photo: NSImage, for name: String) {
		characterPhotos[name] = photo
	}
	
	func photo(for name: String) -> NSImage? {
		let nkey = key(from: name)
		
		guard let photo = characterPhotos[nkey] else {
			return nil
		}
		
		return photo
	}

	#elseif os(iOS)
	
	func addCharacterVoice(_ voice: String, for name: String) {
		let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.\(voice)-compact")
		characterVoices[name] = voice
	}
	
	func voice(for name: String) -> AVSpeechSynthesisVoice {
		let nkey = key(from: name)
		
		guard let voice = try? characterVoices[nkey] else {
			return defaultVoice
		}
		
		return voice
	}
	
	func addCharacterPhoto(_ photo: UIImage, for name: String) {
		characterPhotos[name] = photo
	}
	
	func photo(for name: String) -> UIImage? {
		let nkey = key(from: name)
		
		guard let photo = characterPhotos[nkey] else {
			return nil
		}
		
		return photo
	}
	
	#endif
}

