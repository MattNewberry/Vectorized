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

class HexColorTests: XCTestCase {
	func testEmptyHex() {
		XCTAssertNil(SVGColor(hex: ""))
		XCTAssertNil(SVGColor(hex: "          "))
	}
	
	func testRandomStrings() {
		XCTAssertNil(SVGColor(hex: "this is not a hex string"))
		XCTAssertNil(SVGColor(hex: "1"))
		XCTAssertNil(SVGColor(hex: "#"))
		XCTAssertNotNil(SVGColor(hex: "FFFFFF"))
		XCTAssertNotNil(SVGColor(hex: "#FFF"))
		XCTAssertNil(SVGColor(hex: "#QWERTY"))
	}
	
	func compareHex(hex: String, toWhite whiteCompare: CGFloat) {
		if let color = SVGColor(hex: hex) {
			var white: CGFloat = 0.0
			var alpha: CGFloat = 0.0
			
			color.getWhite(&white, alpha: &alpha)
			
			XCTAssertEqualWithAccuracy(white, whiteCompare, accuracy: CGFloat(FLT_EPSILON))
		} else {
			XCTFail("Color \(hex) should not be nil")
		}
	}
	
	func compareHex(hex: String, toRed redCompare: CGFloat, green greenCompare: CGFloat, blue blueCompare: CGFloat, alpha alphaCompare: CGFloat = 1.0) {
		if let color = SVGColor(hex: hex) {
			var red: CGFloat = 0.0
			var green: CGFloat = 0.0
			var blue: CGFloat = 0.0
			var alpha: CGFloat = 0.0
			
			color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
			
			XCTAssertEqualWithAccuracy(red, redCompare, accuracy: CGFloat(FLT_EPSILON))
			XCTAssertEqualWithAccuracy(green, greenCompare, accuracy: CGFloat(FLT_EPSILON))
			XCTAssertEqualWithAccuracy(blue, blueCompare, accuracy: CGFloat(FLT_EPSILON))
			XCTAssertEqualWithAccuracy(alpha, alphaCompare, accuracy: CGFloat(FLT_EPSILON))
		} else {
			XCTFail("Color \(hex) should not be nil")
		}
	}
	
	func testWhiteHex() {
		compareHex("#FFFFFF", toWhite: 1.0)
		compareHex("ffffff", toWhite: 1.0)
		compareHex("FFF", toWhite: 1.0)
		compareHex("#fff", toWhite: 1.0)
	}
	
	func testBlackHex() {
		compareHex("#000000", toWhite: 0.0)
		compareHex("#000", toWhite: 0.0)
	}
	
	func testRedHex() {
		compareHex("#FF0000", toRed: 1.0, green: 0.0, blue: 0.0)
		compareHex("ff0000", toRed: 1.0, green: 0.0, blue: 0.0)
		compareHex("#f00", toRed: 1.0, green: 0.0, blue: 0.0)
	}
	
	func testGreenHex() {
		compareHex("00FF00", toRed: 0.0, green: 1.0, blue: 0.0)
		compareHex("#00ff00", toRed: 0.0, green: 1.0, blue: 0.0)
		compareHex("0f0", toRed: 0.0, green: 1.0, blue: 0.0)
	}
	
	func testBlueHex() {
		compareHex("#0000FF", toRed: 0.0, green: 0.0, blue: 1.0)
		compareHex("0000ff", toRed: 0.0, green: 0.0, blue: 1.0)
		compareHex("#00f", toRed: 0.0, green: 0.0, blue: 1.0)
	}
	
	func testRGBAHex() {
		compareHex("#FF000000", toRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.0)
		compareHex("00ff00FF", toRed: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
	}
}
