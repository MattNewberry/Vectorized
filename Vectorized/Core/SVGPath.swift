//
//  SVGPath.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/18/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import X
import CoreGraphics

/// An SVGPath is the most common SVGDrawable element in an SVGVectorImage
/// it contains a bezier path and instructions for drawing it to the canvas
/// with its draw() method
public class SVGPath: SVGDrawable, CustomStringConvertible {
    public var identifier: String?
    public var bezierPath: BezierPathType
    public var fill: SVGFillable?
    public var opacity: CGFloat
    public var group: SVGGroup?
    public var clippingPath: BezierPathType?
    
    public var onWillDraw:(()->())?
    public var onDidDraw:(()->())?
    
    public var bounds: CGRect {
		return bezierPath.bounds
	}
	
	public var description: String {
		return "Path"
	}
	
    /// Initializes a SVGPath
    ///
    /// :param: bezierPath The BezierPathType to use for drawing to the canvas
    /// :param: fill An Object conforming to Fillable to use as the fill. ColorType and SVGGradient are common choices
    /// :param: opacity The opacity to draw the path at
    /// :returns: an SVGPath ready for drawing with draw()
    public init(bezierPath: BezierPathType, fill: SVGFillable?, opacity: CGFloat = 1.0, clippingPath: BezierPathType? = nil) {
        self.bezierPath = bezierPath
        self.fill = fill ?? ColorType.blackColor()
        self.opacity = opacity
        self.clippingPath = clippingPath
    }
    
    /// Draws the SVGPath to the canvas
    public func draw() {
        onWillDraw?()
		
        CGContextSaveGState(GetCurrentGraphicsContext())
		
        clippingPath?.addClip()
		
        if let color = fill?.asColor() {
            if opacity != 1 {
                color.colorWithAlphaComponent(opacity).setFill()
            } else {
                color.setFill()
            }
			
            bezierPath.fill()
        } else if let gradient = fill?.asGradient() {
            let context = GetCurrentGraphicsContext()
			
            CGContextSaveGState(context)
			
            bezierPath.addClip()
            gradient.drawGradientWithOpacity(opacity)
			
            CGContextRestoreGState(context)
        }
		
        CGContextRestoreGState(GetCurrentGraphicsContext())
		
        onDidDraw?()
    }
}
