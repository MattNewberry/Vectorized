//
//  SVGGradient.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/19/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import X

/// the SVGGradient protocol extends SVGFillable to specify that the conforming type should
/// be able to supply an CGGradient and modify it with a given opacity when asked
public protocol SVGGradient: SVGFillable {
    var id: String { get }
	var stops: [GradientStop] { get }
	
    func addStop(offset: CGFloat, color: ColorType, opacity: CGFloat)
    func removeStop(stop: GradientStop)
    func drawGradientWithOpacity(opacity: CGFloat)
}

/// Structure defining a gradient stop - contains an offset and a color
public struct GradientStop: Equatable {
    var offset: CGFloat
    var color: ColorType
    var opacity: CGFloat = 1.0
}

public func ==(lhs: GradientStop, rhs: GradientStop) -> Bool {
    return lhs.offset == rhs.offset && lhs.color == rhs.color
}
