//
//  CommonExtensions.swift
//  Story Framework (macOS)
//
//  Created by Emily Blackwell on 04/08/2019.
//  Copyright © 2019 Emily Blackwell. All rights reserved.
//

import Foundation

extension String {
	func matches(for pattern: NSRegularExpression) -> [NSTextCheckingResult] {
		let range = NSMakeRange(0, self.count)
		return pattern.matches(in: self, options: .anchored, range: range)
	}
	
	func index(_ int: Int) -> String.Index {
		return String.Index(utf16Offset: int, in: self)
	}
}
