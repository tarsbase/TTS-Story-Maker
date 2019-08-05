//
//  SyntaxHighlighter.swift
//  TTS Story Maker
//
//  Created by Emily Blackwell on 04/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

import Cocoa

class SyntaxHighlighter: NSObject {
	var commentPattern: NSRegularExpression!
	var speakerPattern: NSRegularExpression!
	var task: DispatchWorkItem?
	var enabled = true
	
	weak var textView: NSTextView!
	
	var speakerColour: NSColor {
		if #available(macOS 10.14, *) {
			return .controlAccentColor
		} else {
			return .systemBlue
		}
	}
	
	init(textView: NSTextView) {
		self.textView = textView
		
		commentPattern = try! NSRegularExpression(pattern: "# ?[^\n]+", options: [])
		speakerPattern = try! NSRegularExpression(pattern: "\n?([a-z\' ]+)\\:", options: .caseInsensitive)
	}
	
	private func stringFrom(range: NSRange, contents: String) -> String {
		let lower = contents.index(range.lowerBound)
		let upper = contents.index(range.upperBound)
		
		let line = contents[lower ..< upper]
		return String(line)
	}
	
	func highlight() {
		task?.cancel()
		
		guard enabled else {
			return
		}
		
		task = DispatchWorkItem { [weak self] in
			self?._highlight()
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now(), execute: task!)
	}
	
	func resetHighlights() {
		let contents = textView.attributedString().mutableCopy() as! NSMutableAttributedString
		let range = NSMakeRange(0, contents.length)
		
		// reset highlighting
		textView.undoManager?.disableUndoRegistration()
		
		contents.addAttributes([.foregroundColor: NSColor.controlTextColor], range: range)
		textView.insertText(contents, replacementRange: range)
		
		textView.undoManager?.enableUndoRegistration()
	}
	
	private func _highlight() {
		let text = textView.string
		let contents = textView.attributedString().mutableCopy() as! NSMutableAttributedString
		let range = NSMakeRange(0, contents.length)
		
		// store the text cursor's current state
		var cursorState: NSValue?
		
		if textView.selectedRanges.count > 0 {
			cursorState = textView.selectedRanges.first
		}
		
		textView.undoManager?.disableUndoRegistration()
		contents.addAttributes([.foregroundColor: NSColor.controlTextColor], range: range)
		
		// find language elements we can highlight
		let comments = commentPattern.matches(in: text, options: [], range: range)
		let speakers = speakerPattern.matches(in: text, options: [], range: range)
		
		for speaker in speakers {
			contents.addAttributes([.foregroundColor: speakerColour], range: speaker.range)
		}
		
		for comment in comments {
			contents.addAttributes([.foregroundColor: NSColor.systemGreen], range: comment.range)
		}
		
		// apply our new highlight
		textView.insertText(contents, replacementRange: range)
		
		// restore the text cursor's position (and the scroll position)
		if let state = cursorState {
			textView.selectedRanges.insert(state, at: 0)
			textView.scrollRangeToVisible(state.rangeValue)
		}
				
		textView.undoManager?.enableUndoRegistration()
	}
}
