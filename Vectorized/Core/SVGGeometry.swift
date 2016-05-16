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

// swiftlint:disable variable_name

import Foundation

public enum SVGUnit: String {
	case Emphemeral = "em"
	// swiftlint:disable type_name
	case Ex = "ex"
	// swiftlint:enable type_name
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
	
	public static var zero = SVGLength(0)
	
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
	
	public static var zero = SVGSize(width: 0, height: 0)
	
	public init(width: SVGLength, height: SVGLength) {
		self.width = width
		self.height = height
	}
	
	public init(width: Float, height: Float) {
		self.init(width: SVGLength(width), height: SVGLength(height))
	}
	
	public init(_ size: CGSize) {
		self.init(width: Float(size.width), height: Float(size.height))
	}
	
	public var description: String {
		return "{SVGSize: width<\(width)> height<\(height)>}"
	}
}

public struct SVGPoint: SVGAttribute, CustomStringConvertible {
	public var x: SVGLength
	public var y: SVGLength
	
	public static var zero = SVGPoint(x: 0, y: 0)
	
	public init(x: SVGLength, y: SVGLength) {
		self.x = x
		self.y = y
	}
	
	public init(x: Float, y: Float) {
		self.init(x: SVGLength(x), y: SVGLength(y))
	}
	
	public init(_ point: CGPoint) {
		self.init(x: Float(point.x), y: Float(point.y))
	}
	
	public var description: String {
		return "{SVGPoint: x<\(x)> y<\(y)>}"
	}
}
