//
//  CharacterTableViewCell.swift
//  TTS Story Maker
//
//  Created by Emily Blackwell on 04/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

import Cocoa

let characterTVCellID = NSUserInterfaceItemIdentifier("characterCell")

class CharacterTableViewCell: NSTableCellView {

	@IBOutlet weak var nameLabel: NSTextField!
	@IBOutlet weak var lineCountLabel: NSTextField!
	@IBOutlet weak var portraitView: NSImageView!
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // make character portraits round!
		if !portraitView.wantsLayer {
			portraitView.wantsLayer = true
			portraitView.layer?.cornerRadius = 24
			portraitView.layer?.masksToBounds = true
		}
		
		// not every picture is perfect, obviously, so let's add a background to maintain
		// the image view's "roundness"
		portraitView.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }
    
}
