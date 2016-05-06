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
	var attributes: [String : SVGAttribute] { get set }
	
	var parent: SVGElement? { get set }
	var children: [SVGElement]? { get set }

	init()
	
	func isPermittedContentElement(element: SVGElement) -> Bool
}

// Element categories
public protocol SVGContainerElement: SVGElement {}
public protocol SVGAnimationElement: SVGElement {}

public protocol SVGShapeElement: SVGElement {
	var bezierPath: SVGBezierPath? { get set }
}

public protocol SVGBasicShapeElement: SVGElement {}
public protocol SVGDescriptiveElement: SVGElement {}
public protocol SVGFilterElement: SVGElement {}
public protocol SVGFontElement: SVGElement {}
public protocol SVGGradientElement: SVGElement {}
public protocol SVGGraphicsElement: SVGElement, SVGDrawable {}
public protocol SVGLightSourceElement: SVGElement {}
public protocol SVGStructuralElement: SVGElement {}
public protocol SVGTextContentElement: SVGElement {}
public protocol SVGTextContentChildElement: SVGElement {}
public protocol SVGUncategorizedElement: SVGElement {}

public extension SVGElement {
	public var description: String {
		return "{SVGElement}"
	}
	
	public func isPermittedContentElement(element: SVGElement) -> Bool {
		return true
	}
	
	mutating func appendChild(child: SVGElement) -> Bool {
		if !isPermittedContentElement(child) {
			return false
		}
		
		if children == nil {
			children = []
		}
		
		var child = child
		
		child.parent = self
		children!.append(child)
		
		return true
	}
}
