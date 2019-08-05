//
//  NewCharacterSheetViewController.swift
//  TTS Story Maker
//
//  Created by Emily Blackwell on 04/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

import Cocoa

enum SheetIntent {
	case Create
	case Update
}

class NewCharacterSheetViewController: NSViewController {
	
	@IBOutlet weak var nameField: NSTextField!
	@IBOutlet weak var voiceTableView: NSTableView!
	@IBOutlet weak var titleLabel: NSTextField!
	@IBOutlet weak var portraitView: ContinuityCameraImageWell!
	
	var intent: SheetIntent = .Create
	var itemToEdit: StoryCharacter!
	
	weak var mainVC: ViewController!
	
	private var openFileDialog: NSOpenPanel!
	
	private var voices: [NSSpeechSynthesizer.VoiceName] = []
	private var ttsPreview: NSSpeechSynthesizer!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		ttsPreview = NSSpeechSynthesizer()
		voices = NSSpeechSynthesizer.availableVoices
		
		portraitView?.openFromFileAction = #selector(openPortrait(sender:))
		portraitView?.responder = self
		
		// set up our voice selection table
		if #available(macOS 10.13, *) {
			voiceTableView?.usesAutomaticRowHeights = true
		} else {
			voiceTableView?.rowHeight = 35
		}
		
		voiceTableView?.dataSource = self
		voiceTableView?.delegate = self
		
		// set up our file dialog
		openFileDialog = NSOpenPanel()
		openFileDialog.allowedFileTypes = NSImage.imageTypes
		
		// re-create the character's configuration
		if intent == .Update {
			titleLabel?.stringValue = "Edit Character"
			
			nameField?.stringValue = itemToEdit.name
			portraitView?.image = NSImage(data: itemToEdit.photo)
			
			for (i, voice) in voices.enumerated() {
				if voice == itemToEdit.voice! {
					voiceTableView?.selectRowIndexes([i], byExtendingSelection: false)
					voiceTableView?.scrollRowToVisible(i)
					break
				}
			}
		}
    }
	
	override func viewWillDisappear() {
		ttsPreview?.stopSpeaking(at: .wordBoundary)
	}
	
	// MARK: Actions
	@IBAction func done(sender: AnyObject) {
		let selected = voiceTableView.selectedRow != -1 ? voiceTableView.selectedRow : 0
		
		let name = nameField.stringValue
		let portrait = portraitView.image ?? NSImage(named: "NoPortrait")!
		let voice = voices[selected]
		
		if intent == .Create {
			mainVC?.newCharacter(name: name, voice: voice, portrait: portrait)
		} else {
			mainVC?.updateCharacter(name: name, voice: voice, portrait: portrait)
		}
		
		dismiss(self)
	}
	
	@IBAction @objc func openPortrait(sender: AnyObject) {
		openFileDialog.begin { response in
			guard response == .OK else {
				return
			}
			
			guard let url = self.openFileDialog.url,
				let image = NSImage(contentsOf: url) else {
					return
			}
			
			self.portraitView?.image = image
		}
	}
}

extension NewCharacterSheetViewController: NSTableViewDataSource, NSTableViewDelegate {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return voices.count
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cell = voiceTableView.makeView(withIdentifier: voiceTVCellID, owner: nil) as! VoiceTableViewCell
		
		cell.nameLabel.stringValue = voices[row].rawValue
		cell.previewButton.tag = row
		
		return cell
	}
	
	// MARK: Actions
	@IBAction func previewVoice(sender: NSButton) {
		ttsPreview.stopSpeaking(at: .wordBoundary)
		ttsPreview.setVoice(voices[sender.tag])
		
		var name = nameField.stringValue
		
		if name.isEmpty {
			name = "Actualy... I don't have a name yet"
		}
		
		ttsPreview.startSpeaking("Hi! My name is, \(name). And this is how I sound like.")
	}
}

extension NewCharacterSheetViewController: NSServicesMenuRequestor {
	func readSelection(from pboard: NSPasteboard) -> Bool {
		guard pboard.canReadItem(withDataConformingToTypes: NSImage.imageTypes) else {
			return false
		}
		
		guard let image = NSImage(pasteboard: pboard) else {
			return false
		}
		
		portraitView?.image = image
		return true
	}
}
