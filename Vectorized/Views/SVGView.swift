//---------------------------------------------------------------------------------------
//  The MIT License (MIT)
//
//  Created by Austin Fitzpatrick on 3/18/15 (the "SwiftVG" project)
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

#if os(OSX)
import AppKit
#else
import UIKit
#endif

/// An SVGView provides a way to display SVGVectorImages to the screen respecting the contentMode property.
@IBDesignable public class SVGView: ViewType {
	@IBInspectable var svgName: String? {
		didSet {
			svgNameChanged()
		}
	}
	
#if os(OSX)
	public var contentMode: ContentMode = .Center {
		didSet {
			needsDisplay = true
		}
	}
#endif
	
	public var vectorImage: SVGVectorImage? {
		didSet {
			needsDisplay = true
		}
	}
	
	public convenience init(vectorImage: SVGVectorImage?) {
		self.init(frame: CGRect(x: 0, y: 0, width: vectorImage?.size.width ?? 0, height: vectorImage?.size.height ?? 0))
		
		self.vectorImage = vectorImage
	}
	
	override public func awakeFromNib() {
		super.awakeFromNib()
		
		if svgName != nil {
			svgNameChanged()
		}
	}
	
	/// When the SVG's name changes we'll reparse the new file
	private func svgNameChanged() {
	#if !TARGET_INTERFACE_BUILDER
		let bundle = NSBundle.mainBundle()
	#else
		let bundle = NSBundle(forClass: self.dynamicType)
	#endif
		
		if let path = bundle.pathForResource(svgName, ofType: "svg") {
			vectorImage = SVGParser(path: path).parse()
		} else {
			vectorImage = nil
		}
		
	}
	 
	/// Draw the SVGVectorImage to the screen - respecting the contentMode property
	override public func drawRect(rect: CGRect) {
		super.drawRect(rect)
		
		if let vectorImage = vectorImage {
			let context = GetCurrentGraphicsContext()
			let translation = vectorImage.translationWithTargetSize(rect.size, contentMode: contentMode)
			let scale = vectorImage.scaleWithTargetSize(rect.size, contentMode: contentMode)
			
			CGContextScaleCTM(context, scale.width, scale.height)
			CGContextTranslateCTM(context, translation.x / scale.width, translation.y / scale.height)
			
			vectorImage.draw()
		}
	}
	
	/// Interface builder drawing code
#if TARGET_INTERFACE_BUILDER
	override func prepareForInterfaceBuilder() {
		svgNameChanged()
	}
#endif
}
