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

/// Defines a linear gradient for filling paths.  Create the gradient and then add stops to prepare it for filling.
public class SVGLinearGradient: SVGGradient {
	public var id: String						// The id of the gradient for lookup
	public var startPoint: CGPoint				// The starting point of the gradient
	public var endPoint: CGPoint				// The ending point of the gradient
	public var transform: CGAffineTransform		// The transform to apply to the gradient
	public var gradientUnits: String			// The units of the gradient TODO
	public var stops: [GradientStop]			// Stops define the colors and percentages along the gradient
	
	/// Initializes an SVGLinearGradient to use as a fill
	///
	/// :param: id The id of the gradient
	/// :param: startPoint the starting point of the gradient
	/// :param: endPoint the ending point of the gradient
	/// :param: gradientUnits the units of the gradient TODO
	/// :param: viewBox the viewBox - used to transform the center point
	/// :returns: an SVGLinearGradient with no stops.  Stops will need to be added with addStop(offset, color)
	public init(id: String, startPoint: CGPoint, endPoint: CGPoint, gradientTransform: String?, gradientUnits: String, viewBox: CGRect) {
		self.id = id
		self.startPoint = startPoint
		self.endPoint = endPoint
		
		if let gradientTransformString = gradientTransform {
			transform = SVGParser.transformFromString(gradientTransformString)//CGAffineTransformMake(CGFloat(a), CGFloat(b), CGFloat(c), CGFloat(d), CGFloat(tx), CGFloat(ty))
		} else {
			transform = CGAffineTransformIdentity
		}
		
		self.startPoint = CGPointApplyAffineTransform(self.startPoint, transform)
		self.endPoint = CGPointApplyAffineTransform(self.endPoint, transform)
		self.startPoint = CGPointMake(self.startPoint.x - viewBox.origin.x, self.startPoint.y - viewBox.origin.y)
		self.endPoint  = CGPointMake(self.endPoint.x - viewBox.origin.x, self.endPoint.y - viewBox.origin.y)
		self.gradientUnits = gradientUnits
		
		stops = []
	}
	
	/// Initializes an SVGLinearGradient to use as a fill - convenience for creating it directly from the attributeDict in the XML
	///
	/// :param: attributeDict the attributeDict directly from the NSXMLParser
	/// :returns: an SVGLinearGradient with no stops.  Stops will need to be added with addStop(offset, color)
	public convenience init(attributeDict: [String: String], viewBox: CGRect) {
		let id = attributeDict["id"]
		let startPoint = CGPoint(x: CGFloat(Float(attributeDict["x1"] ?? "") ?? 0.0), y: CGFloat(Float(attributeDict["y1"] ?? "") ?? 0.0))
		let endPoint = CGPoint(x: CGFloat(Float(attributeDict["x2"] ?? "") ?? 0.0), y: CGFloat(Float(attributeDict["y2"] ?? "") ?? 0.0))
		let gradientTransform = attributeDict["gradientTransform"]
		let gradientUnits = attributeDict["gradientUnits"] ?? ""
		
		self.init(id: id!, startPoint: startPoint, endPoint: endPoint, gradientTransform: gradientTransform, gradientUnits: gradientUnits, viewBox: viewBox)
	}
	
	/// Adds a Stop to the gradient - a Gradient is made up of several stops
	///
	/// :param: offset the offset location of the stop
	/// :color: the color to blend from/towards at this stop
	public func addStop(offset: CGFloat, color: SVGColor, opacity: CGFloat){
		stops.append(GradientStop(offset: offset, color: color, opacity: opacity))
	}
	
	/// Draws the gradient to the current context
	///
	/// :param: opacity modify the colors by adjusting opacity
	public func drawGradientWithOpacity(opacity: CGFloat) {
		let context = SVGGraphicsGetCurrentContext()
		
		CGContextDrawLinearGradient(context, CGGradientWithOpacity(opacity), startPoint, endPoint, [.DrawsBeforeStartLocation, .DrawsAfterEndLocation])
	}
	
	/// Returns a CGGradientRef for drawing to the canvas - after modifing the colors if necsssary with given opacity
	///
	/// :param: opacity The opacity at which to draw the gradient
	/// :returns: A CGGradientRef ready for drawing to a canvas
	private func CGGradientWithOpacity(opacity: CGFloat) -> CGGradientRef {
		return CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), stops.map{$0.color.colorWithAlphaComponent(opacity * $0.opacity).CGColor}, stops.map{$0.offset})!
	}
	
	/// Removes a stop previously added to the gradient.
	///
	/// :param: stop The stop to remove
	public func removeStop(stop: GradientStop) {
		if let index = stops.indexOf(stop){
			stops.removeAtIndex(index)
		}
	}
	
	//MARK: SVGFillable
	
	/// Returns a fillable as a gradient optional
	/// :returns: self, if self is an SVGGradient, or nil
	public func asGradient() -> SVGGradient? {
		return self
	}
	
	/// Returns nil
	/// :returns: self, if self is a SVGColor, or nil
	public func asColor() -> SVGColor? {
		return nil
	}
}
