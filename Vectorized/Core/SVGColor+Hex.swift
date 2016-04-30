//---------------------------------------------------------------------------------------
//	The MIT License (MIT)
//
//	Created by Austin Fitzpatrick on 3/18/15 (the "SwiftVG" project)
//	Modified by Brian Christensen <brian@alienorb.com>
//
//	Copyright (c) 2015 Seedling
//	Copyright (c) 2016 Alien Orb Software LLC
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//---------------------------------------------------------------------------------------

import Foundation

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

/// Initializes a SVGColor with a hex string
/// :param: hexString the string to parse for a hex color
/// :returns: the SVGColor or nil if parsing fails
public extension SVGColor {
	public convenience init?(hex rawHex: String) {
		let hex: String
		
		if rawHex.characters.first == "#" {
			hex = rawHex.substringFromIndex(rawHex.startIndex.advancedBy(1)).uppercaseString
		} else {
			hex = rawHex.uppercaseString
		}
		
		if hex == "FFFFFF" || hex == "FFF" {
			self.init(white: 1.0, alpha: 1.0)
			return
		}
		
		if hex == "000000" || hex == "000" {
			self.init(white: 0.0, alpha: 1.0)
			return
		}

		if hex.isEmpty {
			self.init() // https://bugs.swift.org/browse/SR-704
			return nil
		}
		
		let charset = NSCharacterSet(charactersInString: "#0123456789ABCDEF")
		
		if hex.rangeOfCharacterFromSet(charset.invertedSet, options: [], range: nil) != nil {
			self.init()
			return nil
		}
		
		var intValue: UInt32 = 0

		NSScanner(string: hex).scanHexInt(&intValue)
		
		let r, g, b, a: UInt32
		
		switch hex.characters.count {
		case 3: // RGB "short hex"
			(r, g, b, a) = ((intValue & 0xF00) >> 8 * 17, (intValue & 0xF0) >> 4 * 17, (intValue & 0xF) * 17, 255)
		case 6: // RGB
			(r, g, b, a) = ((intValue & 0xFF0000) >> 16, (intValue & 0xFF00) >> 8, (intValue & 0xFF), 255)
		case 8: // RGBA
			(r, g, b, a) = ((intValue & 0xFF000000) >> 24, (intValue & 0xFF0000) >> 16, (intValue & 0xFF00) >> 8, (intValue & 0xFF))
		default:
			self.init()
			return nil
		}
		
		self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
	}
}
