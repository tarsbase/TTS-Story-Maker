//
//  VoiceTableViewCell.swift
//  TTS Story Maker
//
//  Created by Emily Blackwell on 04/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

import Cocoa

let voiceTVCellID = NSUserInterfaceItemIdentifier("voiceCell")

class VoiceTableViewCell: NSTableCellView {
	
	@IBOutlet weak var nameLabel: NSTextField!
	@IBOutlet weak var previewButton: NSButton!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}
