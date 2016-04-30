//
//  SVGGradient.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/18/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import X
import CoreGraphics

/// Defines a radial gradient for filling paths.  Create the gradient and then add stops to prepare it for filling.
public class SVGRadialGradient: SVGGradient {
    public var id: String
    public var center: CGPoint
    public var radius: CGFloat
    public var transform: CGAffineTransform
    public var gradientUnits: String
    public var stops: [GradientStop]
    
    /// Initializes an SVGRadialGradient to use as a fill
    ///
    /// :param: id The id of the gradient
    /// :param: center The center point of the gradient - before transform is applied
    /// :param: radius The radius of the gradient
    /// :param: gradientUnits the units of the gradient TODO
    /// :param: viewBox the viewBox - used to transform the center point
    /// :returns: an SVGRadialGradient with no stops.  Stops will need to be added with addStop(offset, color)
    public init(id: String, center: CGPoint, radius: CGFloat, gradientTransform: String?, gradientUnits: String, viewBox: CGRect) {
        self.id = id
        self.center = center
        self.radius = radius
		
        if let gradientTransform = gradientTransform {
            transform = SVGParser.transformFromString(gradientTransform)
        } else {
            transform = CGAffineTransformIdentity
        }
		
        self.radius = self.radius * transform.a
        self.center = CGPointApplyAffineTransform(self.center, transform)
        self.center = CGPointMake(self.center.x - viewBox.origin.x, self.center.y - viewBox.origin.y)
        self.gradientUnits = gradientUnits
		
        stops = []
    }
    
    /// Initializes an SVGRadialGradient to use as a fill - convenience for creating it directly from the attributeDict in the XML
    ///
    /// :param: attributeDict the attributeDict directly from the NSXMLParser
    /// :returns: an SVGRadialGradient with no stops.  Stops will need to be added with addStop(offset, color)
    public convenience init(attributeDict: [NSObject: AnyObject], viewBox: CGRect) {
        let id = attributeDict["id"] as! String
        let center = CGPoint(x: CGFloat((attributeDict["cx"] as! NSString).floatValue), y: CGFloat((attributeDict["cy"] as! NSString).floatValue))
        let radius = CGFloat((attributeDict["r"] as! NSString).floatValue)
        let gradientTransform = attributeDict["gradientTransform"] as? String
        let gradientUnits = attributeDict["gradientUnits"] as! String
		
        self.init(id: id, center:center, radius: radius, gradientTransform: gradientTransform, gradientUnits:gradientUnits, viewBox: viewBox)
    }
    
    /// Draws the gradient to the current context
    ///
    /// :param: opacity modify the colors by adjusting opacity
    public func drawGradientWithOpacity(opacity: CGFloat) {
        let context = GetCurrentGraphicsContext()

        CGContextDrawRadialGradient(context, CGGradientWithOpacity(opacity), center, 0, center, radius, [.DrawsBeforeStartLocation, .DrawsAfterEndLocation])
    }

    /// Adds a Stop to the gradient - a Gradient is made up of several stops
    ///
    /// :param: offset the offset location of the stop
    /// :color: the color to blend from/towards at this stop
    public func addStop(offset: CGFloat, color: ColorType, opacity: CGFloat) {
        stops.append(GradientStop(offset: offset, color: color, opacity:opacity))
    }
	
    /// Returns a CGGradientRef for drawing to the canvas - after modifing the colors if necsssary with given opacity
    ///
    /// :param: opacity The opacity at which to draw the gradient
    /// :returns: A CGGradientRef ready for drawing to a canvas
    private func CGGradientWithOpacity(opacity: CGFloat) -> CGGradientRef {
        return CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), stops.map {
			$0.color.colorWithAlphaComponent(opacity * $0.opacity).CGColor
		}, stops.map {
			$0.offset
		})!
    }
    
    /// Removes a stop previously added to the gradient.
    ///
    /// :param: stop The stop to remove
    public func removeStop(stop: GradientStop) {
        if let index = stops.indexOf(stop) {
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
    /// :returns: self, if self is a ColorType, or nil
    public func asColor() -> ColorType? {
        return nil
    }

}