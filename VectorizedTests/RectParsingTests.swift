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
@testable import Vectorized

class RectParsingTests: XCTestCase {
	func rectNoFail(parseValue: String?) -> CGRect? {
		do {
			return try CGRect(parseValue: parseValue)
		} catch {
			XCTFail("Should not throw: \(parseValue!), \(error)")
			return nil
		}
	}
	
	func testEmptyValues() {
		XCTAssertNil(rectNoFail(""))
		XCTAssertNil(rectNoFail("           "))
	}
	
	func testRectValues() {
		if let rect = rectNoFail("0 0 3 2") {
			XCTAssertTrue(CGRectEqualToRect(CGRect(x: 0, y: 0, width: 3, height: 2), rect))
		} else {
			XCTFail("Should not be nil")
		}
		
		if let rect = rectNoFail("    25,   30    41,     22         ") {
			XCTAssertTrue(CGRectEqualToRect(CGRect(x: 25, y: 30, width: 41, height: 22), rect))
		} else {
			XCTFail("Should not be nil")
		}
	}
	
	func testGarbageValues() {
		XCTAssertThrowsError(try CGRect(parseValue: "garbage"))
		XCTAssertThrowsError(try CGRect(parseValue: "this is not a proper rect string"))
	}
	
	func testMalformedValues() {
		XCTAssertThrowsError(try CGRect(parseValue: "0 0 3"))
		XCTAssertThrowsError(try CGRect(parseValue: "0 0 3 2 5 2 1"))
	}
}
