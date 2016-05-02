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

extension SVGLength: SVGAttributeParsing {
	init?(parseValue: String?, location: (Int, Int)? = nil) throws {
		guard let value = SVGParser.sanitizedValue(parseValue) else { return nil }
		
		let scanner = NSScanner(string: value, skipCommas: true)
		var length: Float = 0
		
		if !scanner.scanFloat(&length) {
			throw SVGError.InvalidAttributeValue(parseValue!, location: location, message: "Expected length value")
		}
		
		if scanner.atEnd {
			self.init(length)
			return
		}

		let rest = value.substringFromIndex(value.startIndex.advancedBy(scanner.scanLocation)).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		
		if rest.isEmpty {
			self.init(length)
			return
		}

		if let unit = SVGUnit(rawValue: rest) {
			self.init(length, unit)
			return
		} else {
			throw SVGError.InvalidMeasurementUnit(parseValue!, location: location, message: "Expected unit or nothing")
		}
	}
}
