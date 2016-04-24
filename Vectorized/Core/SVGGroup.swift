//---------------------------------------------------------------------------------------
//  The MIT License (MIT)
//
//  Created by Austin Fitzpatrick on 3/19/15 (the "SwiftVG" project)
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

/// an SVGGroup contains a set of SVGDrawable objects, which could be SVGPaths or SVGGroups.
public class SVGGroup: SVGDrawable, CustomStringConvertible {
    public var group: SVGGroup? // The parent of this group, if any
    public var clippingPath: BezierPathType?
    public var identifier: String?
    
    public var onWillDraw: (()->())?
    public var onDidDraw: (()->())?
	
	internal var drawables: [SVGDrawable]
	
	/// Prints the contents of the group
	public var description: String {
		return "{Group<\(drawables.count)> (\(clippingPath != nil)): \(drawables)}"
	}
	
    /// Initialies and empty SVGGroup
    ///
    /// :returns: an SVGGroup with no drawables
    public init() {
        drawables = []
    }
    
    /// Initializes an SVGGroup pre-populated with drawables
    /// 
    /// :param: drawables the drawables to populate the group with
    /// :returns: an SVGGroup pre-populated with drawables
    public init(drawables: [SVGDrawable]) {
        self.drawables = drawables
    }

    /// Draws the SVGGroup to the screen by iterating through its contained SVGDrawables
    public func draw() {
        onWillDraw?()
		
        CGContextSaveGState(GetCurrentGraphicsContext())
		
        if let clippingPath = clippingPath {
            clippingPath.addClip()
        }
		
        for drawable in drawables {
            drawable.draw()
        }
		
        CGContextRestoreGState(GetCurrentGraphicsContext())
		
        onDidDraw?()
    }
    
    /// Adds an SVGDrawable (SVGDrawable) to the group - and sets that SVGDrawable's group property
    /// to point at this SVGGroup
    ///
    /// :param: drawable an SVGDrawable/SVGDrawable to add to this group
    public func addToGroup(drawable: SVGDrawable) {
        var groupable = drawable
		
        drawables.append(groupable)
        groupable.group = self
    }
}
