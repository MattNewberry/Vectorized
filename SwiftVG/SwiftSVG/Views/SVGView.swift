//
//  SVGView.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/18/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import UIKit

/// An SVGView provides a way to display SVGVectorImages to the screen respecting the contentMode property.
@IBDesignable class SVGView: UIView {
    
    @IBInspectable var svgName:String?  // The name of the SVG - mostly for interface builder
        { didSet { svgNameChanged() } }
    var svg:SVGVectorImage?             // The vector image to draw to the screen
        { didSet { setNeedsDisplay() } }
    
    //MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        if let svgName = svgName { svgNameChanged() }
    }
    
    /// When the SVG's name changes we'll reparse the new file
    func svgNameChanged() {
        #if !TARGET_INTERFACE_BUILDER
            let bundle = NSBundle.mainBundle()
        #else
            let bundle = NSBundle(forClass: self.dynamicType)
        #endif
        if let path = bundle.pathForResource(svgName, ofType: "svg") {
            let parser = SVGParser(path: path)
            svg = parser.parse()
        } else {
            svg = nil
        }

    }
    
    /// Draw the SVGVectorImage to the screen - respecting the contentMode property
    override func drawRect(rect: CGRect) {
        if let svg = self.svg {
            let targetSize = svg.size
            switch contentMode {
            case .ScaleAspectFit:
                let scaleFactor = min(bounds.width / targetSize.width, bounds.height / targetSize.height)
                let scale = CGSizeMake(scaleFactor, scaleFactor)
                let newSize = CGSize(width: targetSize.width * scale.width, height: targetSize.height * scale.height)
                let xTranslation = (bounds.width - newSize.width) / 2.0
                let yTranslation = (bounds.height - newSize.height) / 2.0
                CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale.width, scale.height)
                CGContextTranslateCTM(UIGraphicsGetCurrentContext(), xTranslation / scale.width, yTranslation / scale.height)
            case .ScaleAspectFill:
                let scaleFactor = max(bounds.width / targetSize.width, bounds.height / targetSize.height)
                let scale = CGSizeMake(scaleFactor, scaleFactor)
                let newSize = CGSize(width: targetSize.width * scale.width, height: targetSize.height * scale.height)
                let xTranslation = (bounds.width - newSize.width) / 2.0
                let yTranslation = (bounds.height - newSize.height) / 2.0
                CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale.width, scale.height)
                CGContextTranslateCTM(UIGraphicsGetCurrentContext(), xTranslation / scale.width, yTranslation / scale.height)
            case .ScaleToFill:
                let scaleFactor = CGSize(width:bounds.width / targetSize.width, height: bounds.height / targetSize.height)
                CGContextScaleCTM(UIGraphicsGetCurrentContext(), scaleFactor.width, scaleFactor.height)
            case .Center:
                let offset = CGPointMake((targetSize.width - bounds.width) / 2, (targetSize.height - bounds.height) / 2)
                CGContextTranslateCTM(UIGraphicsGetCurrentContext(), offset.x, offset.y)
            default: break
                
            }
            svg.draw()
        }
    }
    
    /// Interface builder drawing code
    override func prepareForInterfaceBuilder() {
        svgNameChanged()
        setNeedsDisplay()
    }
}
