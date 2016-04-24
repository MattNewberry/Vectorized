//
//  SVGText.swift
//  Seedling Comic
//
//  Created by Austin Fitzpatrick on 3/23/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import X
import CoreGraphics

public class SVGText: SVGDrawable {
    public var group: SVGGroup?
    public var clippingPath: BezierPathType?
    public var text: String?
    public var transform: CGAffineTransform?
    public var fill: SVGFillable?
    public var font: FontType?
    public var viewBox: CGRect?
    public var identifier: String?
    
    public var onWillDraw: (()->())?
    public var onDidDraw: (()->())?
    
    public init() {}
    
    /// Draws the text to the current context
    public func draw() {
        onWillDraw?()
		
        let color = fill?.asColor() ?? ColorType.whiteColor()
        let attributes: [String: AnyObject] = [NSFontAttributeName: font ?? FontType.systemFontOfSize(24), NSForegroundColorAttributeName: color]
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: text!, attributes: attributes))
        var ascent = CGFloat(0)
		
        CTLineGetTypographicBounds(line, &ascent, nil, nil)
		
        let offsetToConvertSVGOriginToAppleOrigin = -ascent
        let context = GetCurrentGraphicsContext()
		
        CGContextSaveGState(context)
        CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-viewBox!.origin.x, -viewBox!.origin.y))
        CGContextConcatCTM(context, transform!)

        let size = (text! as NSString).sizeWithAttributes(attributes)
        let p = CGPointMake(0, offsetToConvertSVGOriginToAppleOrigin)
		
        (text! as NSString).drawInRect(CGRectMake(p.x, p.y, size.width, size.height), withAttributes: attributes)
		
		CGContextRestoreGState(context)
		
        onDidDraw?()
    }
    
}