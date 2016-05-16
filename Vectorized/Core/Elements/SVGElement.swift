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

public protocol SVGElement: CustomStringConvertible {
	var name: String { get }
	var attributes: [SVGAttributeName : SVGAttribute] { get set }
	var children: [SVGElement]? { get set }

	init()
	
	func isPermittedChild(element: SVGElement) -> Bool
}

public extension SVGElement {
	public var description: String {
		return "{SVGElement <\(name)>}"
	}
	
	public func isPermittedChild(element: SVGElement) -> Bool {
		return true
	}
	
	mutating func appendChild(child: SVGElement) -> Bool {
		if !isPermittedChild(child) {
			return false
		}

		if children == nil {
			children = []
		}
		
		children!.append(child)
		
		return true
	}
}

// Element categories
public protocol SVGContainerElement: SVGElement {}
public protocol SVGAnimationElement: SVGElement {}
public protocol SVGDescriptiveElement: SVGElement {}
public protocol SVGFilterElement: SVGElement {}
public protocol SVGFontElement: SVGElement {}
public protocol SVGGradientElement: SVGElement {}

public protocol SVGGraphicsElement: SVGElement, SVGDrawable {}

public protocol SVGShapeElement: SVGGraphicsElement {
	var bezierPath: SVGBezierPath? { get }
}

public extension SVGShapeElement {
	public var stroke: SVGStroke? {
		return attributes[.Stroke] as? SVGStroke
	}
	
	public var fill: SVGFill? {
		return attributes[.Fill] as? SVGFill
	}
	
	public func draw(renderer: SVGRenderer) {
		guard let bezierPath = bezierPath else { return }
		
		if let fill = fill {
			if let color = fill.color {
				color.setFill()
				bezierPath.fill()
			}
		}
		
		if let stroke = stroke {
			if let color = stroke.color {
				color.setStroke()
			}
			
			if let width = stroke.width {
				bezierPath.lineWidth = CGFloat(width.value)
			}
			
			if bezierPath.lineWidth > 0 {
				bezierPath.stroke()
			}
		}
	}
}

public protocol SVGBasicShapeElement: SVGShapeElement {}

public protocol SVGLightSourceElement: SVGElement {}
public protocol SVGStructuralElement: SVGElement {}
public protocol SVGTextContentElement: SVGElement {}
public protocol SVGTextContentChildElement: SVGElement {}
public protocol SVGUncategorizedElement: SVGElement {}
