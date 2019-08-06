//
//  CharacterDialogueTally.swift
//  TTS Story Maker
//
//  Created by Emily Blackwell on 04/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

import Foundation

protocol TallyDelegate {
	func tallyIsAvailable(tally: [Int])
}

class CharacterDialogueTally: NSObject {
	weak var project: StoryProject!
	
	private var task: DispatchWorkItem?
	private var speakerPattern: NSRegularExpression!
	
	var delegate: TallyDelegate?
	
	init(project: StoryProject) {
		self.project = project
		
		speakerPattern = try! NSRegularExpression(pattern: "\n?([a-z\' ]+)\\:", options: .caseInsensitive)
	}
	
	func tally() {
		task?.cancel()
		
		task = DispatchWorkItem { [weak self] in
			let lines = self?._tally()
			
			DispatchQueue.main.async {
				self?.delegate?.tallyIsAvailable(tally: lines ?? [])
			}
		}
		
		DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now(), execute: task!)
	}
	
	private func _tally() -> [Int] {
		var count: [Int] = []
		
		guard project != nil else {
			return []
		}
		
		for _ in project.characters {
			count.append(0)
		}
		
		for line in project.script.split(separator: "\n") {
			let line = String(line)
			
			if line.matches(for: speakerPattern).count > 0 {
				let name = line.replacingOccurrences(of: ":", with: "")
				
				for (i, character) in project.characters.enumerated() {
					if character.name == name {
						count[i] += 1
						break
					}
				}
			}
		}
		
		return count
	}
}
