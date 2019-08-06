//
//  StoryProject.swift
//  TTS Story Maker
//
//  Created by Emily Blackwell on 04/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

import Foundation

let projectType = "tssproject"

fileprivate let kCharacters = "characters"
fileprivate let kScript = "script"

class StoryProject: NSObject {
	var script: String!
	var characterNames: [String] = []
	
	var characters: [StoryCharacter] = [] {
		didSet {
			characterNames = []
			
			for character in characters {
				characterNames.append(character.name)
			}
		}
	}
	
	var story: ISStory!
	
	override init() {
		super.init()
		story = ISStory()
	}
	
	func readFrom(string: String) {
		story.readFrom(string: string)
	}
	
	// MARK: File I/O
	
	func save(to url: URL) {
		let data = NSMutableData()
		let file = NSKeyedArchiver(forWritingWith: data)
		
		file.encode(characters, forKey: kCharacters)
		file.encode(script, forKey: kScript)
		file.finishEncoding()
		
		try? data.write(to: url, options: .atomicWrite)
	}
	
	func load(from file: URL, done: ((String, [StoryCharacter]) -> ())? = nil) {
		guard let data = try? Data(contentsOf: file) else {
			return
		}
		
		let file = NSKeyedUnarchiver(forReadingWith: data)
		
		if let characters = file.decodeObject(forKey: kCharacters) as? [StoryCharacter] {
			self.characters = characters
		}
		
		if let script = file.decodeObject(forKey: kScript) as? String {
			self.script = script
		}
		
		done?(script, characters)
	}
}
