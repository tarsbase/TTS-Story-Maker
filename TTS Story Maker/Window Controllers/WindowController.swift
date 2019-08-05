//
//  WindowController.swift
//  TTS Story Maker
//
//  Created by Emily Blackwell on 04/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
	
	var mainVC: ViewController!
	var project: StoryProject!
	var lastFile: URL?
	
	var saveDialog: NSSavePanel!
	var openDialog: NSOpenPanel!
	
	@IBOutlet weak var savingIndicator: NSProgressIndicator!

    override func windowDidLoad() {
        super.windowDidLoad()
		
		project = StoryProject()
    
		guard let mvc = contentViewController as? ViewController else {
			return
		}
		
		mainVC = mvc
		mainVC?.project = project
		mainVC?.initialiseTallyController()
		
		setIndicator(active: false)
		
		// initialise our file dialogs
		saveDialog = NSSavePanel()
		saveDialog.allowedFileTypes = [projectType]
		
		openDialog = NSOpenPanel()
		openDialog.allowedFileTypes = [projectType]
		openDialog.allowsMultipleSelection = false
    }
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == "toPlayback" {
			// build our story structure
			let source = mainVC.sourceTextView.string
			project.readFrom(string: source)
			
			// bind portraits and voices to the characters
			for character in project.characters {
				project.story.addCharacterPhoto(NSImage(data: character.photo)!, for: character.name)
				project.story.addCharacterVoice(character.voice, for: character.name)
			}
			
			// pass our project data
			let dvc = segue.destinationController as! PlaybackWindowController
			dvc.set(story: project.story)
		}
	}

	func setIndicator(active: Bool) {
		DispatchQueue.main.async {
			self.savingIndicator?.isHidden = !active
			
			if active {
				self.savingIndicator?.startAnimation(self)
			} else {
				self.savingIndicator?.stopAnimation(self)
			}
		}
	}
	
	// MARK: Actions
	
	@IBAction func newCharacter(sender: AnyObject) {
		mainVC?.performSegue(withIdentifier: "newCharacter", sender: self)
	}
	
	@IBAction func run(sender: AnyObject) {
		performSegue(withIdentifier: "toPlayback", sender: self)
	}
	
	@IBAction func new(sender: AnyObject) {
		let alert = NSAlert()
		alert.informativeText = "Any unsaved progress will be lost!"
		alert.messageText = "Are you sure?"
		alert.addButton(withTitle: "Cancel")
		alert.addButton(withTitle: "Create New Story")
		
		alert.beginSheetModal(for: window!) { response in
			guard response == .alertSecondButtonReturn else {
				return
			}
			
			self.project.script = ""
			self.project.characters.removeAll()
			self.mainVC?.refresh()
			
			self.lastFile = nil
		}
	}
	
	@IBAction func save(sender: AnyObject) {
		// we can only do one save operation at a time!
		guard savingIndicator.isHidden else {
			let alert = NSAlert()
			alert.messageText = "Sorry"
			alert.informativeText = "You can't do that again, since, guess what... your project is still saving!"
			alert.addButton(withTitle: "Ok")
			
			alert.beginSheetModal(for: window!, completionHandler: nil)
			return
		}
		
		self.setIndicator(active: true)
		
		if let url = lastFile {
			DispatchQueue.global(qos: .userInitiated).async {
				self.project?.save(to: url)
				self.setIndicator(active: false)
			}
			
			return
		}
		
		saveDialog.beginSheetModal(for: window!) { response in
			guard response == .OK else {
				self.setIndicator(active: false)
				return
			}
			
			self.lastFile = self.saveDialog.url
			
			DispatchQueue.global(qos: .userInitiated).async {
				self.project?.save(to: self.saveDialog.url!)
				self.setIndicator(active: false)
			}
		}
	}
	
	@IBAction func open(sender: AnyObject) {
		openDialog.beginSheetModal(for: window!) { response in
			guard response == .OK else {
				return
			}
			
			self.lastFile = self.openDialog.url
			
			self.project?.load(from: self.openDialog.url!) { _, _ in
				self.mainVC?.refresh()
			}
		}
	}
}
