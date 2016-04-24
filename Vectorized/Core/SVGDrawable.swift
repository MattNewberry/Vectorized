//
//  File.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/19/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import X

// An SVGDrawable can be drawn to the screen.  To conform a type must implement one method, draw()
public protocol SVGDrawable {
	var identifier: String? { get set }
	var group: SVGGroup? { get set }
	var clippingPath: BezierPathType? { get set }
	
	var onWillDraw: (()->())? { get set }
	var onDidDraw: (()->())? { get set }
	
	func draw()
}
