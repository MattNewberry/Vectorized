//
//  SVGGroup.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/19/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

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
