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

public enum SVGUnit: String {
	case Emphemeral = "em"
	case Ex = "ex"
	case Pixel = "px"
	case Inch = "in"
	case Centimeter = "cm"
	case Millimeter = "mm"
	case Point = "pt"
	case Pica = "pc"
	case Percent = "%"
}

public struct SVGLength: SVGAttribute, CustomStringConvertible {
	public var value: Float
	public var unit: SVGUnit?
	
	public init(_ value: Float, _ unit: SVGUnit? = nil) {
		self.value = value
		self.unit = unit
	}
	
	public var description: String {
		return "{SVGLength: \(value)\(unit != nil ? unit!.rawValue : "")}"
	}
}

public struct SVGSize: SVGAttribute, CustomStringConvertible {
	public var width: SVGLength
	public var height: SVGLength
	
	public init(width: SVGLength, height: SVGLength) {
		self.width = width
		self.height = height
	}
	
	public var description: String {
		return "{SVGSize: width<\(width)> height<\(height)>}"
	}
}

public struct SVGPoint: SVGAttribute, CustomStringConvertible {
	public var x: SVGLength
	public var y: SVGLength
	
	public init(x: SVGLength, y: SVGLength) {
		self.x = x
		self.y = y
	}
	
	public init(x: Float, y: Float) {
		self.init(x: SVGLength(x), y: SVGLength(y))
	}
	
	public var description: String {
		return "{SVGPoint: x<\(x)> y<\(y)>}"
	}
}

public var SVGLengthZero: SVGLength {
get { return SVGLength(0) }
}

public var SVGSizeZero: SVGSize {
get { return SVGSize(width: SVGLength(0), height: SVGLength(0)) }
}

public var SVGPointZero: SVGPoint {
get { return SVGPoint(x: 0, y: 0) }
}
