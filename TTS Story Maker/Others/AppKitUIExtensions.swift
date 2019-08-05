//
//  AppKitUIExtensions.swift
//  TTS Story Maker
//
//  Created by Emily Blackwell on 05/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

import Cocoa

@IBDesignable class CircularImageView: NSImageView {
	
	@IBInspectable var roundness: CGFloat = 100 {
		didSet {
			self.wantsLayer = true
			layer?.backgroundColor = .black
			layer?.masksToBounds = true
			layer?.cornerRadius = roundness
		}
	}
}

class ContinuityCameraImageWell: NSImageView {
	
	var openFromFileAction: Selector!
	var responder: NSViewController!
	
	override func mouseDown(with event: NSEvent) {
		let menu = NSMenu(title: "Contextual Menu")
		
		let fromFile = NSMenuItem(title: "Import from file", action: openFromFileAction, keyEquivalent: "")
		menu.addItem(fromFile)
		
		NSMenu.popUpContextMenu(menu, with: event, for: self)
	}
	
	override func validRequestor(forSendType sendType: NSPasteboard.PasteboardType?, returnType: NSPasteboard.PasteboardType?) -> Any? {
		if let pasteboardType = returnType,
			NSImage.imageTypes.contains(pasteboardType.rawValue) {
			return responder
		} else {
			return super.validRequestor(forSendType: sendType, returnType: returnType)
		}
	}
}
