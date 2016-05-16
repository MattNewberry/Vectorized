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

import CoreGraphics

public protocol SVGRenderer {
	//var fillColor: SVGColor { get set }
	//var strokeColor: SVGColor { get set }
	
	//func fill()
	//func stroke()
	
	func saveGraphicsState()
	func restoreGraphicsState()
	
	func scale(scale: CGSize)
	func translate(translation: CGPoint)
}

extension CGContext: SVGRenderer {
	public func saveGraphicsState() {
		CGContextSaveGState(self)
	}
	
	public func restoreGraphicsState() {
		CGContextRestoreGState(self)
	}
	
	public func scale(scale: CGSize) {
		CGContextScaleCTM(self, scale.width, scale.height)
	}
	
	public func translate(translation: CGPoint) {
		CGContextTranslateCTM(self, translation.x, translation.y)
	}
}
