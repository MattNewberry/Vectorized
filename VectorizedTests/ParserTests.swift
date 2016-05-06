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

import XCTest
import Foundation
@testable import Vectorized

class ParserTests: XCTestCase {
	func parserNoThrow(path: String) -> SVGParser {
		var parser: SVGParser?
		
		do {
			parser = try SVGParser(path: path)
		} catch {
			XCTFail("Shouldn't throw: \(path)")
		}
		
		return parser!
	}
	
	func testEmptyPath() {
		XCTAssertThrowsError(try SVGParser(path: ""))
		parserNoThrow("non/existent/but/not/empty.xml")
	}
	
	func testNonexistentParse() {
		let parser = parserNoThrow("non_existent.xml")

		XCTAssertThrowsError(try parser.parse())
		XCTAssertNotNil(parser.parserError)
		print("\(parser.parserError!)")
	}
	
	func testBasicShapesRect() {
		let parser = parserNoThrow(NSBundle(forClass: self.dynamicType).pathForResource("shapes-rect-01-t", ofType: "svg")!)

		XCTAssertNil(parser.parserError)
		
		do {
			try parser.parse()
		} catch {
			XCTFail("Shouldn't throw any error: \(error)")
		}
	}
}
