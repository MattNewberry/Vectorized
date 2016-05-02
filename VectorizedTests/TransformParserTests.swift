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

//class TransformParserTests: XCTestCase {
//	func transformFromStringNoFail(string: String?) -> CGAffineTransform {
//		do {
//			return try SVGParser.transformFromString(string)
//		} catch {
//			XCTFail("Should not throw: \(string!), \(error)")
//			return CGAffineTransformIdentity
//		}
//	}
//	
//	func testEmptyStrings() {
//		XCTAssertTrue(CGAffineTransformIsIdentity(transformFromStringNoFail(nil)))
//		XCTAssertTrue(CGAffineTransformIsIdentity(transformFromStringNoFail("")))
//		XCTAssertTrue(CGAffineTransformIsIdentity(transformFromStringNoFail("              ")))
//	}
//	
//	func testMatrixSpaceSeparated() {
//		let comparison = CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6)
//		
//		var transform = transformFromStringNoFail("matrix(1 2 3 4 5 6)")
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//		
//		transform = transformFromStringNoFail("matrix(1    2.0  3    4.0  5      6)")
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//		
//		transform = transformFromStringNoFail("matrix(        1.0000000    2.0  3.0000    4     5      6         )")
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//		
//		transform = transformFromStringNoFail("      matrix       (1 2 3 4 5 6)")
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//	}
//	
//	func testMatrixCommaSeparated() {
//		let comparison = CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6)
//		
//		var transform = transformFromStringNoFail("matrix(1,2,3,4,5,6)")
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//		
//		transform = transformFromStringNoFail("matrix(     1,2.0000,    3.0     ,   4    , 5,6      )")
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//	}
//	
//	func testMatrixMalformed() {
//		XCTAssertThrowsError(try SVGParser.transformFromString("matrix"))
//		XCTAssertThrowsError(try SVGParser.transformFromString("matrix(0)"))
//		XCTAssertThrowsError(try SVGParser.transformFromString("matrix ( 1 2 3 4 5 )"))
//		XCTAssertThrowsError(try SVGParser.transformFromString("matrix(1,2,3,4,5,6"))
//		XCTAssertThrowsError(try SVGParser.transformFromString("matrix(this is a garbage value)"))
//	}
//	
//	func testTranslate() {
//		var comparison = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 5, ty: 6)
//		
//		var transform = transformFromStringNoFail("translate(5 6)")
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//		
//		transform = transformFromStringNoFail("translate(5,6)")
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//		
//		comparison = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 5, ty: 0)
//		
//		transform = transformFromStringNoFail("translate(5)")
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//	}
//	
//	func testScale() {
//		var comparison = CGAffineTransform(a: 15, b: 0, c: 0, d: 30, tx: 0, ty: 0)
//		var transform = transformFromStringNoFail("scale(15, 30)")
//		
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//		
//		comparison = CGAffineTransform(a: 35, b: 0, c: 0, d: 0, tx: 0, ty: 0)
//		transform = transformFromStringNoFail("scale(35)")
//		
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//	}
//	
//	func testRotate() {
//		var comparison = CGAffineTransformMakeRotation(90)
//		var transform = transformFromStringNoFail("rotate(90)")
//		
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//		
//		comparison = CGAffineTransformMakeTranslation(15, 20)
//		comparison = CGAffineTransformRotate(comparison, 90)
//		comparison = CGAffineTransformTranslate(comparison, -15, -20)
//		
//		transform = transformFromStringNoFail("rotate(90 15 20)")
//		
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//	}
//	
//	func testRotateMalformed() {
//		XCTAssertThrowsError(try SVGParser.transformFromString("rotate"))
//		XCTAssertThrowsError(try SVGParser.transformFromString("rotate(45,15"))
//	}
//	
//	func testCombinedCommands() {
//		var comparison = CGAffineTransformConcat(CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 5, ty: 6), CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6))
//		var transform = transformFromStringNoFail("matrix(1 2 3 4 5 6) translate(5,6)")
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//		
//		comparison = CGAffineTransformConcat(CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6), CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 5, ty: 6))
//		transform = transformFromStringNoFail("translate(5,6) matrix(1 2 3 4 5 6)")
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//	}
//	
//	func testUnrecognizedCommands() {
//		let comparison = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 5, ty: 6)
//		let transform = transformFromStringNoFail("unrecognized translate(5 6) ignore_this(unrecognized 0 1 2)")
//		XCTAssertTrue(CGAffineTransformEqualToTransform(comparison, transform), "\(transform)")
//	}
//}
