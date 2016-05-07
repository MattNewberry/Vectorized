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

class KeywordColorTests: XCTestCase {
	func compareKeyword(keyword: SVGColorKeyword, _ redCompare: Int, _ greenCompare: Int, _ blueCompare: Int, _ alphaCompare: Int = 255) {
		return compareKeyword(keyword.rawValue, redCompare, greenCompare, blueCompare, alphaCompare)
	}
	
	func compareKeyword(keyword: String, _ redCompare: Int, _ greenCompare: Int, _ blueCompare: Int, _ alphaCompare: Int = 255) {
		if let color = SVGColor(keyword: keyword) {
			var red: CGFloat = 0.0
			var green: CGFloat = 0.0
			var blue: CGFloat = 0.0
			var alpha: CGFloat = 0.0
			
			color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
			
			XCTAssertEqualWithAccuracy(red, CGFloat(redCompare) / 255.0, accuracy: CGFloat(FLT_EPSILON))
			XCTAssertEqualWithAccuracy(green, CGFloat(greenCompare) / 255.0, accuracy: CGFloat(FLT_EPSILON))
			XCTAssertEqualWithAccuracy(blue, CGFloat(blueCompare) / 255.0, accuracy: CGFloat(FLT_EPSILON))
			XCTAssertEqualWithAccuracy(alpha, CGFloat(alphaCompare) / 255.0, accuracy: CGFloat(FLT_EPSILON))
		} else {
			XCTFail("Color \(keyword) should not be nil")
		}
	}
	
	func testEmpty() {
		XCTAssertNil(SVGColor(keyword: ""))
		XCTAssertNil(SVGColor(keyword: "             "))
	}
	
	func testGarbage() {
		XCTAssertNil(SVGColor(keyword: "this is not a valid color"))
		XCTAssertNil(SVGColor(keyword: "10239072q05kdlADSFASKDFASFOP24290"))
	}
	
	func testKeywords() {
		compareKeyword(.Black, 0, 0, 0)
		compareKeyword(.Blue, 0, 0, 255)
		compareKeyword(.Azure, 240, 255, 255)
		compareKeyword("honeydew", 240, 255, 240)
	}
}
