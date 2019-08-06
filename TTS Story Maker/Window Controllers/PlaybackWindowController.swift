//
//  PlaybackWindowController.swift
//  TTS Story Maker
//
//  Created by Emily Blackwell on 04/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

import Cocoa

class PlaybackWindowController: NSWindowController {
	
	@IBOutlet weak var seekSlider: NSSlider!
	var mainVC: PlaybackViewController!
	
    override func windowDidLoad() {
        super.windowDidLoad()
    
		guard let mvc = contentViewController as? PlaybackViewController else {
			return
		}
		
		mainVC = mvc
    }
	
	func set(story: ISStory) {
		mainVC?.story = story
		mainVC?.delegate = self
		
		seekSlider?.doubleValue = 0
		seekSlider?.maxValue = Double(story.scenes.count)
		
		// no scene guard
		guard story.scenes.count > 0 else {
			let alert = NSAlert()
			alert.messageText = "You have no scenes in your story!"
			alert.informativeText = "I mean... what did you expect when you clicked play with an empty script?"
			alert.addButton(withTitle: "Ok, I'll go write some scenes...")
			
			alert.runModal()
			
			DispatchQueue.main.async {
				self.close()
			}
			
			return
		}
	}
	
	// MARK: Actions
	@IBAction func bye(sender: AnyObject) {
		close()
	}
	
	@IBAction func skipNext(sender: AnyObject) {
		mainVC?.next(sender: sender)
	}
	
	@IBAction func skipPrevious(sender: AnyObject) {
		mainVC?.previous(sender: sender)
	}
	
	@IBAction func seek(sender: NSSlider) {
		mainVC?.seek(position: sender.integerValue)
	}
}

extension PlaybackWindowController: PlaybackDelegate {
	func positionUpdated(current: Int) {
		seekSlider?.doubleValue = Double(current)
	}
}

extension PlaybackWindowController: EditorDelegate {
	func editorWasClosed() {
		close()
	}
}
