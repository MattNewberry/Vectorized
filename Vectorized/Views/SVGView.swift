//---------------------------------------------------------------------------------------
//	The MIT License (MIT)
//
//	Created by Austin Fitzpatrick on 3/18/15 (the "SwiftVG" project)
//	Modified by Brian Christensen <brian@alienorb.com>
//
//	Copyright (c) 2015 Seedling
//	Copyright (c) 2016 Alien Orb Software LLC
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//---------------------------------------------------------------------------------------

#if os(OSX)
	import AppKit
	
	public typealias BaseView = NSView
#else
	import UIKit
	
	public typealias BaseView = UIView
#endif

/// An SVGView provides a way to display SVGGraphics to the screen respecting the contentMode property.
@IBDesignable public class SVGView: BaseView {
	@IBInspectable var vectorGraphicName: String? {
		didSet {
			svgNameChanged()
		}
	}
	
#if os(OSX)
	public var contentMode: SVGContentMode = .Center {
		didSet {
			setNeedsDisplay()
		}
	}
#endif
	
	public var document: SVGDocument? {
		didSet {
			setNeedsDisplay()
		}
	}
	
	public convenience init(document: SVGDocument?) {
		self.init(frame: CGRect(x: 0, y: 0, width: CGFloat(document?.size.width.value ?? 0), height: CGFloat(document?.size.height.value ?? 0)))
		
		self.document = document
	}

	/// When the SVG's name changes we'll reparse the new file
	private func svgNameChanged() {
		guard vectorGraphicName != nil else {
			document = nil
			return
		}
		
	#if !TARGET_INTERFACE_BUILDER
		let bundle = NSBundle.mainBundle()
	#else
		let bundle = NSBundle(forClass: self.dynamicType)
	#endif
		
		if let path = bundle.pathForResource(vectorGraphicName, ofType: "svg"), parser = SVGParser(path: path) {
			do {
				let documents = try parser.parse()
				document = documents.first
			} catch {
				Swift.print("\(self): The SVG parser encountered an error: \(error)")
				document = nil
			}
		} else {
			Swift.print("\(self): SVG resource named '\(vectorGraphicName!)' was not found!")
			document = nil
		}
	}
	
	override public func drawRect(rect: CGRect) {
		super.drawRect(rect)
		
		if let document = document {
			if let context = SVGGraphicsGetCurrentContext() {
			//	let translation = vectorGraphic.translationWithTargetSize(rect.size, contentMode: contentMode)
			//	let scale = vectorGraphic.scaleWithTargetSize(rect.size, contentMode: contentMode)
				
				#if os(OSX)
					let flipVertical = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: -1.0, tx: 0.0, ty: rect.size.height)
					CGContextConcatCTM(context, flipVertical)
				#endif
				
			//	CGContextScaleCTM(context, scale.width, scale.height)
			//	CGContextTranslateCTM(context, translation.x / scale.width, translation.y / scale.height)
				
				document.draw()
			}
		}
	}
	
	/// Interface builder drawing code
#if TARGET_INTERFACE_BUILDER
	override func prepareForInterfaceBuilder() {
		svgNameChanged()
	}
#endif
}
