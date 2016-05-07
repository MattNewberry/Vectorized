//---------------------------------------------------------------------------------------
//	The MIT License (MIT)
//
//	Created by Austin Fitzpatrick on 3/19/15 (the "SwiftVG" project)
//	Modified by Brian Christensen <brian@alienorb.com>
//
//	Copyright (c) 2015 Seedling
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

import CoreGraphics

// An SVGDrawable can be drawn to the screen.  To conform a type must implement one method, draw()
public protocol SVGDrawable: SVGElement {
//	var onWillDraw: (()->())? { get set }
//	var onDidDraw: (()->())? { get set }
	
	func draw(intoContext context: CGContext)
	func drawChildren(intoContext context: CGContext)
}

public extension SVGDrawable {
	private func drawChildren(startingAtRoot root: SVGElement, intoContext context: CGContext) {
		if let children = root.children {
			for child in children {
				if let drawable = child as? SVGDrawable {
					CGContextSaveGState(context)
					drawable.draw(intoContext: context)
					CGContextRestoreGState(context)
				}
				
				drawChildren(startingAtRoot: child, intoContext: context)
			}
		}
	}
	
	public func draw(intoContext context: CGContext) {
		drawChildren(intoContext: context)
	}
	
	public func drawChildren(intoContext context: CGContext) {
		drawChildren(startingAtRoot: self, intoContext: context)
	}
}
