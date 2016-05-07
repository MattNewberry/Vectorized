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

public final class SVGRect: SVGBasicShapeElement, SVGShapeElement, SVGGraphicsElement {
	public var attributes: [String : SVGAttribute] = [:]
	
	public var parent: SVGElement?
	public var children: [SVGElement]?
	
	public var bezierPath: SVGBezierPath?
	
	public var position: SVGPoint {
		get { return attributes["position"] as? SVGPoint ?? SVGPointZero }
	}
	
	public var size: SVGSize {
		get { return attributes["size"] as? SVGSize ?? SVGSizeZero }
	}
	
	public var cornerRadius: SVGPoint {
		get {
			if let rx = attributes["rx"] as? SVGLength, ry = attributes["ry"] as? SVGLength {
				return SVGPoint(x: rx, y: ry)
			}
			
			return SVGPointZero
		}
	}
	
	private var _bezierPath: SVGBezierPath?
	
	public init() {}

	public func isPermittedContentElement(element: SVGElement) -> Bool {
		switch element {
		case _ as SVGAnimationElement: fallthrough
		case _ as SVGDescriptiveElement:
			return true
			
		default:
			return false
		}
	}
	
	public func draw(intoContext context: CGContext) {
		if bezierPath == nil {
			let rect = CGRect(x: CGFloat(position.x.value), y: CGFloat(position.y.value), width: CGFloat(size.width.value), height: CGFloat(size.height.value))
			
			bezierPath = SVGBezierPath(rect: rect)
		}
		
		SVGColor.blackColor().setStroke()
		bezierPath!.stroke()
		
		drawChildren(intoContext: context)
	}
}
