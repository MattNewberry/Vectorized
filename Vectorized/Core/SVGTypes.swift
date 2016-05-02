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

public struct SVGLength {
	public var value: CGFloat
	public var unit: SVGUnit?
	
	public init(value: CGFloat, unit: SVGUnit? = nil) {
		self.value = value
		self.unit = unit
	}
}

public struct SVGSize {
	public var width: SVGLength
	public var height: SVGLength
	
	public init(width: SVGLength, height: SVGLength) {
		self.width = width
		self.height = height
	}
}
