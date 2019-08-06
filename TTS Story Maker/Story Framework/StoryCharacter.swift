//
//  StoryCharacter.swift
//  TTS Story Maker
//
//  Created by Emily Blackwell on 04/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

import Foundation
import Cocoa

fileprivate let kName = "name"
fileprivate let kVoice = "voice"
fileprivate let kData = "data"

class StoryCharacter: NSObject, NSCoding {
	
	var name: String!
	var photo: Data!
	
	var voice: NSSpeechSynthesizer.VoiceName!
	
	init(name: String, voice: NSSpeechSynthesizer.VoiceName, photo: Data?) {
		self.name = name
		self.voice = voice
		self.photo = photo
	}
	
	// MARK: NSCoding
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(name, forKey: kName)
		aCoder.encode(voice, forKey: kVoice)
		aCoder.encode(photo, forKey: kData)
	}
	
	required init?(coder aDecoder: NSCoder) {
		if let name = aDecoder.decodeObject(forKey: kName) as? String {
			self.name = name
		}
		
		if let voice = aDecoder.decodeObject(forKey: kVoice) as? NSSpeechSynthesizer.VoiceName {
			self.voice = voice
		}
		
		if let photo = aDecoder.decodeObject(forKey: kData) as? Data {
			self.photo = photo
		}
	}
}
