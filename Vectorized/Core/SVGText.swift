//---------------------------------------------------------------------------------------
//  The MIT License (MIT)
//
//  Created by Austin Fitzpatrick on 3/23/15 (the "SwiftVG" project)
//	Modified by Brian Christensen <brian@alienorb.com>
//
//  Copyright (c) 2015 Seedling
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
		
        let color = fill?.asColor() ?? Color.whiteColor()
        let attributes: [String: AnyObject] = [NSFontAttributeName: font ?? Font.systemFontOfSize(24), NSForegroundColorAttributeName: color]
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