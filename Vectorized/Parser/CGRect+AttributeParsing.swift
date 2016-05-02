//---------------------------------------------------------------------------------------
//	The MIT License (MIT)
//
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

extension CGRect: SVGAttribute, SVGAttributeParsing {
	init?(parseValue: String?, location: (Int, Int)? = nil) throws {
		guard let value = SVGParser.sanitizedValue(parseValue) else { return nil }
		
		let scanner = NSScanner(string: value, skipCommas: true)
		var x: Float = 0, y: Float = 0, width: Float = 0, height: Float = 0
		
		if !scanner.scanFloat(&x) || !scanner.scanFloat(&y) || !scanner.scanFloat(&width) || !scanner.scanFloat(&height) {
			throw SVGError.InvalidAttributeValue(parseValue!, location: location, message: "Expected x, y, width, height")
		}
		
		if width < 0 || height < 0 {
			throw SVGError.InvalidAttributeValue(parseValue!, location: location, message: "Expected non-negative width and height")
		}
		
		if !scanner.atEnd {
			throw SVGError.InvalidAttributeValue(parseValue!, location: location, message: "Expected end of value")
		}
		
		self.init(x: CGFloat(x), y: CGFloat(y), width: CGFloat(width), height: CGFloat(height))
	}
}
