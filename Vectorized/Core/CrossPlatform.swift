//---------------------------------------------------------------------------------------
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Alien Orb Software LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//---------------------------------------------------------------------------------------

#if os(OSX)
	import AppKit
	import CoreGraphics
	
	public typealias SVGBezierPath = NSBezierPath
	public typealias SVGColor = NSColor
	public typealias SVGFont = NSFont
	public typealias SVGImage = NSImage
	
	public enum SVGViewContentMode: Int {
		case ScaleToFill
		case ScaleAspectFit
		case ScaleAspectFill
		case Redraw
		case Center
		case Top
		case Bottom
		case Left
		case Right
		case TopLeft
		case TopRight
		case BottomLeft
		case BottomRight
	}
	
	public func SVGGraphicsGetCurrentContext() -> CGContextRef? {
		if #available(OSXApplicationExtension 10.10, *) {
			return NSGraphicsContext.currentContext()?.CGContext
		} else {
			fatalError("NSGraphicsContext.CGContext requires 10.10 or later")
		}
	}
	
	extension NSBezierPath {
		public func appendPath(bezierPath: NSBezierPath) {
			appendBezierPath(bezierPath)
		}
		
		public func applyTransform(transform: CGAffineTransform) {
			let nsTransform = NSAffineTransform()
			
			nsTransform.transformStruct = NSAffineTransformStruct(m11: transform.a, m12: transform.b, m21: transform.c, m22: transform.d, tX: transform.tx, tY: transform.ty)
			
			transformUsingAffineTransform(nsTransform)
		}
		
		public func addLineToPoint(point: CGPoint) {
			lineToPoint(point)
		}
		
		public func addCurveToPoint(endPoint: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
			curveToPoint(endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
		}
		
		public func addQuadCurveToPoint(endPoint: CGPoint, controlPoint: CGPoint) {
			let controlPoint1 = CGPoint(x: currentPoint.x + (2.0 / 3.0) * (controlPoint.x - currentPoint.x), y: currentPoint.y + (2.0 / 3.0) * (controlPoint.y - currentPoint.y))
			
			let controlPoint2 = CGPoint(x: endPoint.x + (2.0 / 3.0) * (controlPoint.x - endPoint.x), y: endPoint.y + (2.0 / 3.0) * (controlPoint.y - endPoint.y))
			
			addCurveToPoint(endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
		}
		
		public var usesEvenOddFillRule: Bool {
			get {
				return windingRule == .EvenOddWindingRule
			}
			set {
				windingRule = newValue == true ? .EvenOddWindingRule : .NonZeroWindingRule
			}
		}
	}
#else
	import UIKit
	
	public typealias SVGBezierPath = UIBezierPath
	public typealias SVGColor = UIColor
	public typealias SVGFont = NSFont
	public typealias SVGImage = UIImage
	
	public typealias SVGViewContentMode = UIViewContentMode
	
	public func SVGGraphicsGetCurrentContext() -> CGContextRef? {
		return UIGraphicsGetCurrentContext()
	}
#endif
