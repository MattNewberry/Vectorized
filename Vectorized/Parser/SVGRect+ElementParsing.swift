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

extension SVGRect: SVGElementParsing {
	convenience init(parseAttributes attributes: [String : String], location: (Int, Int)?) throws {
		self.init()
		
		if let x = try SVGLength(parseValue: attributes["x"], location: location) {
			position.x = x
		}
		
		if let y = try SVGLength(parseValue: attributes["y"], location: location) {
			position.y = y
		}
		
		let width = try SVGLength(parseValue: attributes["width"], location: location)
		let height = try SVGLength(parseValue: attributes["height"], location: location)
		
		if width != nil || height != nil {
			size = SVGSize(width: width ?? SVGLength(0), height: height ?? SVGLength(0))
		}
		
		if size.width.value < 0 || size.height.value < 0 {
			throw SVGError.InvalidAttributeValue("\(size)", location: location, message: "Expected non-negative width and height")
		}
		
		if let rx = try SVGLength(parseValue: attributes["rx"], location: location) {
			cornerRadius.x = rx
		}
		
		if let ry = try SVGLength(parseValue: attributes["ry"], location: location) {
			cornerRadius.y = ry
		}
	}
	
	func endElement() throws {}
}
