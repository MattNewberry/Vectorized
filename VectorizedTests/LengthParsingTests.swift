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

class LengthParsingTests: XCTestCase {
	func lengthNoFail(parseValue: String?) -> SVGLength? {
		do {
			return try SVGLength(parseValue: parseValue)
		} catch {
			XCTFail("Should not throw: \(parseValue!), \(error)")
			return nil
		}
	}
	
	func testEmptyValue() {
		XCTAssertNil(lengthNoFail(""))
		XCTAssertNil(lengthNoFail("           "))
	}
	
	func testWithoutUnits() {
		let length = lengthNoFail("265.03")

		XCTAssertNotNil(length)
		XCTAssertEqualWithAccuracy(length!.value, 265.03, accuracy: 0.01)
	}
	
	func testWithUnits() {
		var length = lengthNoFail("50em")
		
		XCTAssertNotNil(length)
		XCTAssertEqualWithAccuracy(length!.value, 50, accuracy: 0.01)
		XCTAssertEqual(length!.unit, SVGUnit.Emphemeral)
		
		length = lengthNoFail("   5      px     ")
		
		XCTAssertNotNil(length)
		XCTAssertEqualWithAccuracy(length!.value, 5, accuracy: 0.01)
		XCTAssertEqual(length!.unit, SVGUnit.Pixel)
	}
	
	func testGarbage() {
		XCTAssertThrowsError(try SVGLength(parseValue: "invalid"))
		XCTAssertThrowsError(try SVGLength(parseValue: "5x"))
		XCTAssertThrowsError(try SVGLength(parseValue: "25px 30px"))
	}
}
