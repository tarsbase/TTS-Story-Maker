//
//  ViewController.swift
//  TTS Story Maker
//
//  Created by Emily Blackwell on 04/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

import Cocoa

protocol EditorDelegate {
	func editorWasClosed()
}

class ViewController: NSViewController {
	
	@IBOutlet weak var sourceTextView: NCRAutocompleteTextView!
	@IBOutlet weak var charactersTableView: NSTableView!
	@IBOutlet weak var noCharactersLabel: NSTextField!
	
	var highlighter: SyntaxHighlighter!
	
	weak var project: StoryProject!
	var delegate: EditorDelegate?
	
	var tallyController: CharacterDialogueTally!
	
	private var prefDelegateKey = ""
	private var lastText: String!
	var editMode = false
	
	var autocompleteEnabled = true

	override func viewDidLoad() {
		super.viewDidLoad()
		
		highlighter = SyntaxHighlighter(textView: sourceTextView)
		
		// set up our source editor
		sourceTextView?.lnv_setUpLineNumberView()
		sourceTextView?.font = NSFont.systemFont(ofSize: 18)
		sourceTextView?.textColor = .controlTextColor
		sourceTextView?.ncrDelegate = self
		lastText = sourceTextView.string
		
		// set up our character table view
		if #available(macOS 10.13, *) {
			charactersTableView?.usesAutomaticRowHeights = true
		} else {
			charactersTableView?.rowHeight = 64
		}
		
		charactersTableView?.doubleAction = #selector(beginEdit)
		charactersTableView?.dataSource = self
		charactersTableView?.delegate = self
		
		// load our user preferences
		loadPreferences()
		
		// initial highlight
		sourceTextView?.string += "\n"
		highlighter.highlight()
		
		// assign it a unique delegate identifier
		prefDelegateKey = PreferencesController.shared.uniqueKey(name: "editor")
		PreferencesController.shared.add(delegate: self, with: prefDelegateKey)
	}
	
	func initialiseTallyController() {
		// initialise our tally controller
		tallyController = CharacterDialogueTally(project: project)
		tallyController.delegate = self
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == "newCharacter" {
			let dvc = segue.destinationController as! NewCharacterSheetViewController
			dvc.mainVC = self
			
			if editMode {
				editMode = false
				
				guard let row = charactersTableView?.selectedRow else {
					return
				}
				
				dvc.itemToEdit = project.characters[row]
				dvc.intent = .Update
			} 
		}
	}
	
	// MARK: Actions
	@objc func beginEdit() {
		editMode = true
		performSegue(withIdentifier: "newCharacter", sender: self)
	}
}

extension ViewController: NCRAutocompleteTableViewDelegate {
	// MARK: Autocomplete Delegate
	
	// updated to work with NCRAutocompleteTextView
	func textWillBeChecked() {
		// sync text changes back to our project
		project?.script = sourceTextView.string
		
		if lastText != sourceTextView.string {
			// process our text here
			highlighter.highlight()
			tallyController?.tally()
			
			lastText = sourceTextView.string
		}
	}

	func textView(_ textView: NSTextView!, completions words: [Any]!, forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>!) -> [Any]! {
		
		guard autocompleteEnabled else {
			return []
		}
		
		guard let contents = sourceTextView?.string else {
			return []
		}
		
		var suggestions = project.characterNames 
		
		// get the word the user is currently typing
		let lower = contents.index(charRange.lowerBound)
		let upper = contents.index(charRange.upperBound)
		
		let typedWord = String(contents[lower ..< upper])
		
		if !typedWord.isEmpty {
			suggestions = suggestions.filter { item in
				return item.starts(with: typedWord)
			}
		}
		
		return suggestions
	}
	
	func textView(_ textView: NSTextView!, imageForCompletion word: String!) -> NSImage! {
		for character in project.characters {
			if character.name == word {
				return NSImage(data: character.photo)
			}
		}
		
		return nil
	}
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
	// MARK: Table View Delegate
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return project?.characters.count ?? 0
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cell = charactersTableView.makeView(withIdentifier: characterTVCellID, owner: nil) as! CharacterTableViewCell
		
		let character = project.characters[row]
		cell.nameLabel.stringValue = character.name
		cell.portraitView.image = NSImage(data: character.photo)
		
		return cell
	}
	
	@available (OSX 10.11, *)
	func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
		
		if edge == .leading {
			return []
		}
		
		let deleteAction = NSTableViewRowAction(style: .destructive, title: "Delete") { _, row in
			self.project.characters.remove(at: row)
			tableView.removeRows(at: [row], withAnimation: .slideUp)
			
			// hide/show our "no characters" label
			self.noCharactersLabel?.isHidden = self.project.characters.count > 0
		}
		
		return [deleteAction]
	}
	
	// MARK: Actions
	func newCharacter(name: String, voice: NSSpeechSynthesizer.VoiceName, portrait: NSImage) {
		let data = portrait.tiffRepresentation
		let character = StoryCharacter(name: name, voice: voice, photo: data)
		
		// insert it to our table view with a sliding animation
		let row = project.characters.count
		project.characters.append(character)
		
		charactersTableView?.insertRows(at: [row], withAnimation: .slideDown)
		noCharactersLabel?.isHidden = project.characters.count > 0
	}
	
	func updateCharacter(name: String, voice: NSSpeechSynthesizer.VoiceName, portrait: NSImage) {
		// insert it to our table view with a sliding animation
		guard let row = charactersTableView?.selectedRow else {
			return
		}
		
		let data = portrait.tiffRepresentation
		
		project.characters[row].name = name
		project.characters[row].voice = voice
		project.characters[row].photo = data
		
		charactersTableView?.reloadData(forRowIndexes: [row], columnIndexes: [0])
	}
	
	func refresh() {
		noCharactersLabel?.isHidden = project.characters.count > 0
		sourceTextView?.string = project?.script ?? ""
		charactersTableView?.reloadData()
		
		// update our text processors
		highlighter.highlight()
		tallyController.tally()
	}
}

extension ViewController: TallyDelegate {
	// MARK: Tally Delegate
	
	func tallyIsAvailable(tally: [Int]) {
		for (i, count) in tally.enumerated() {
			let cell = charactersTableView.view(atColumn: 0, row: i, makeIfNecessary: false) as! CharacterTableViewCell
			
			cell.lineCountLabel.stringValue = "\(count) lines"
		}
	}
}

extension ViewController: PreferencesDelegate {
	// MARK: Preferences Delegate
	
	func loadPreferences() {
		let defaults = PreferencesController.shared.defaults
		
		let useAutoCorrect = defaults.value(forKey: KTPEditorAutoCorrectSuggest) as! Bool
		let highlightsSyntax = defaults.value(forKey: KTPEditorSyntaxHighlighting) as! Bool
		let lineNumbers = defaults.value(forKey: KTPEditorLineNumbers) as? Bool ?? false
		autocompleteEnabled = defaults.value(forKey: KTPEditorAutocompletionEnabled) as? Bool ?? true
		
		settingUpdated(key: KTPEditorAutoCorrectSuggest, value: useAutoCorrect)
		settingUpdated(key: KTPEditorSyntaxHighlighting, value: highlightsSyntax)
		settingUpdated(key: KTPEditorAutocompletionEnabled, value: autocompleteEnabled)
		settingUpdated(key: KTPEditorLineNumbers, value: lineNumbers)
	}
	
	func settingUpdated(key: String, value: Any?) {
		if key == KTPEditorAutoCorrectSuggest {
			guard let useAutoCorrect = value as? Bool else {
				return
			}
			
			sourceTextView?.isContinuousSpellCheckingEnabled = useAutoCorrect
			sourceTextView?.isAutomaticSpellingCorrectionEnabled = useAutoCorrect
			sourceTextView?.isGrammarCheckingEnabled = useAutoCorrect
		}
		
		else if key == KTPEditorSyntaxHighlighting {
			guard let highlightsSyntax = value as? Bool else {
				return
			}
			
			highlighter?.enabled = highlightsSyntax
			
			// reset text attributes
			if !highlightsSyntax {
				highlighter.resetHighlights()
			} else {
				highlighter.highlight()
			}
		}
		
		else if key == KTPEditorAutocompletionEnabled {
			guard let enabled = value as? Bool else {
				return
			}
			
			autocompleteEnabled = enabled
		}
		
		else if key == KTPEditorLineNumbers {
			guard let enabled = value as? Bool else {
				return
			}
			
			sourceTextView?.enclosingScrollView?.rulersVisible = enabled
		}
	}
}

extension ViewController: NSWindowDelegate {
	// MARK: Window Delegate
	
	func windowWillClose(_ notification: Notification) {
		PreferencesController.shared.delete(delegate: prefDelegateKey)
		delegate?.editorWasClosed()
	}
}
