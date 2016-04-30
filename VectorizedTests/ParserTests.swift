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

class ParserTests: XCTestCase {
	func testEmptyPath() {
		XCTAssertNil(SVGParser(path: ""))
		XCTAssertNotNil(SVGParser(path: "non/existent/but/not/empty.xml"))
	}
	
	func testNonexistentParse() {
		let parser = SVGParser(path: "non_existent.xml")!

		XCTAssertThrowsError(try parser.parse())
		XCTAssertNotNil(parser.parserError)
		print("\(parser.parserError!)")
	}
	
	func transformFromStringNoFail(string: String?) -> CGAffineTransform {
		do {
			return try SVGParser.transformFromString(string)
		} catch {
			XCTFail("Should not throw: \(string!), \(error)")
			return CGAffineTransformIdentity
		}
	}
	
	func testTransformFromStringEmpty() {
		XCTAssertTrue(CGAffineTransformIsIdentity(transformFromStringNoFail(nil)))
		XCTAssertTrue(CGAffineTransformIsIdentity(transformFromStringNoFail("")))
		XCTAssertTrue(CGAffineTransformIsIdentity(transformFromStringNoFail("              ")))
	}
	
	func testTransformFromStringMatrixSpaceSeparated() {
		let comparison = CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6)
		
		var transform = transformFromStringNoFail("matrix(1 2 3 4 5 6)")
		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
		
		transform = transformFromStringNoFail("matrix(1    2.0  3    4.0  5      6)")
		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
		
		transform = transformFromStringNoFail("matrix(        1.0000000    2.0  3.0000    4     5      6         )")
		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
	}
	
	func testTransformFromStringMatrixCommaSeparated() {
		let comparison = CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6)

		let transform = transformFromStringNoFail("matrix(1,2,3,4,5,6)")
		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
	}
}
