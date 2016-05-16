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

import Foundation

public struct SVGRect: SVGBasicShapeElement, SVGShapeElement, SVGGraphicsElement {
	public private(set) var name: String = "rect"
	public var attributes: [SVGAttributeName : SVGAttribute] = [:]
	public var children: [SVGElement]?
	
	public var bezierPath: SVGBezierPath? {
		let position = self.position
		let size = self.size
		let rect = CGRect(x: CGFloat(position.x.value), y: CGFloat(position.y.value), width: CGFloat(size.width.value), height: CGFloat(size.height.value))
		let radius = self.cornerRadius
		
		return SVGBezierPath(roundedRect: rect, xRadius: CGFloat(radius.x.value), yRadius: CGFloat(radius.y.value))
	}
	
	public var position: SVGPoint {
		get { return attributes[.Position] as? SVGPoint ?? SVGPoint.zero }
	}
	
	public var size: SVGSize {
		get { return attributes[.Size] as? SVGSize ?? SVGSize.zero }
	}
	
	public var cornerRadius: SVGPoint {
		get {
			if let rx = attributes[.RadiusX] as? SVGLength, ry = attributes[.RadiusY] as? SVGLength {
				return SVGPoint(x: rx, y: ry)
			}
			
			return SVGPoint.zero
		}
	}
	
	public init() {}

	public func isPermittedChild(element: SVGElement) -> Bool {
		switch element {
		case _ as SVGAnimationElement: fallthrough
		case _ as SVGDescriptiveElement:
			return true
			
		default:
			return false
		}
	}
}
