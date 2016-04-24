//
//  Fillable.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/18/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import X

/// Protocol shared by objects capable of acting as a fill for an SVGPath
public protocol SVGFillable: class {
	func asColor() -> ColorType?
	func asGradient() -> SVGGradient?
}

/// Extend UIColor to conform to SVGFillable
extension ColorType: SVGFillable {
    public func asColor() -> ColorType? { return self }
    public func asGradient() -> SVGGradient? { return nil}
}
