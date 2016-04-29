//
//  BezierPathTests.swift
//  Vectorized
//
//  Created by Brian Christensen on 4/28/16.
//  Copyright © 2016 Alien Orb Software LLC. All rights reserved.
//

import XCTest
@testable import Vectorized

class BezierPathTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
	
	func testEmptyPathDescriptions() {
		XCTAssertTrue(SVGBezierPath(SVGPathDescription: "").empty)
		XCTAssertTrue(SVGBezierPath(SVGPathDescription: "               ").empty)
	}
}
