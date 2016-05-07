//---------------------------------------------------------------------------------------
//	The MIT License (MIT)
//
//	Created by Austin Fitzpatrick on 3/19/15 (the "SwiftVG" project)
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

import Foundation
import CoreGraphics

public final class SVGDocument: SVGContainerElement, SVGStructuralElement, SVGDrawable {
	public var attributes: [SVGAttributeName : SVGAttribute] = [:]
	
	public var parent: SVGElement?
	public var children: [SVGElement]?
	
	public var version: String? {
		get { return attributes[.Version] as? String ?? nil }
	}
	
	public var position: SVGPoint {
		get { return attributes[.Position] as? SVGPoint ?? SVGPointZero }
	}
	
	public var size: SVGSize {
		get { return attributes[.Size] as? SVGSize ?? SVGSize(width: SVGLength(100, .Percent), height: SVGLength(100, .Percent)) }
	}
	
	public var viewBox: CGRect? {
		get { return attributes[.ViewBox] as? CGRect ?? nil }
	}
	
	public var description: String {
		return "{SVGDocument: \(children)}"
	}
	
	public init() {}
	
	public convenience init?(contentsOfFile path: String) {
		do {
			try self.init(contentsOfFile_throws: path)
		} catch {
			Swift.print("SVGDocument.init: The SVG parser encountered an error: \(error)")
			return nil
		}
	}
	
	public convenience init(contentsOfFile_throws path: String) throws {
		self.init()
		
		try parseFile(path)
	}
	
	public convenience init?(named name: String) {
		do {
			try self.init(named_throws: name)
		} catch {
			Swift.print("SVGDocument.init: The SVG parser encountered an error: \(error)")
			return nil
		}
	}
	
	public convenience init(named_throws name: String) throws {
		self.init()
		
	#if !TARGET_INTERFACE_BUILDER
		let bundle = NSBundle.mainBundle()
	#else
		let bundle = NSBundle(forClass: self.dynamicType)
	#endif
		
		if let path = bundle.pathForResource(name, ofType: "svg") {
			try parseFile(path)
		} else {
			throw SVGError.BundleResourceNotFound(name)
		}
	}
	
	private func parseFile(path: String) throws {
		let parser = try SVGParser(path: path)
		let root = try parser.parse()
		
		attributes = root.attributes
		children = root.children
	}
	
	public func draw(intoContext context: CGContext, frameRect: CGRect, contentMode: SVGContentMode) {
		CGContextSaveGState(context)
		
		let translation = translationWithTargetSize(frameRect.size, contentMode: contentMode)
		let scale = scaleFactorWithTargetSize(frameRect.size, contentMode: contentMode)
		
		CGContextScaleCTM(context, scale.width, scale.height)
		CGContextTranslateCTM(context, translation.x / scale.width, translation.y / scale.height)
		
		drawElement(intoContext: context)
		
		CGContextRestoreGState(context)
	}
	
	public func draw(intoContext context: CGContext) {
		if let viewBox = viewBox {
			CGContextTranslateCTM(context, viewBox.origin.x, viewBox.origin.y)
		}
	}
	
	private func scaleFactorWithTargetSize(targetSize: CGSize, contentMode: SVGContentMode) -> CGSize {
		guard let viewBox = viewBox else { return CGSize.zero }

		switch contentMode {
		case .ScaleAspectFit:
			let scaleFactor = min(targetSize.width / viewBox.size.width, targetSize.height / viewBox.size.height)
			return CGSize(width: scaleFactor, height: scaleFactor)
			
		case .ScaleAspectFill:
			let scaleFactor = max(targetSize.width / viewBox.size.width, targetSize.height / viewBox.size.height)
			return CGSize(width: scaleFactor, height: scaleFactor)
			
		case .ScaleToFill:
			return CGSize(width: targetSize.width / viewBox.size.width, height: targetSize.height / viewBox.size.height)
			
		case .Center:
			return CGSize(width: 1, height: 1)
			
		default:
			return CGSize(width: 1, height: 1)
		}
	}
	
	private func translationWithTargetSize(targetSize: CGSize, contentMode: SVGContentMode) -> CGPoint {
		guard let viewBox = viewBox else { return CGPoint.zero }
		
		var newSize: CGSize
		
		switch contentMode {
		case .ScaleAspectFit:
			let scaleFactor = min(targetSize.width / viewBox.size.width, targetSize.height / viewBox.size.height)
			let scale = CGSize(width: scaleFactor, height: scaleFactor)
			
			newSize = CGSize(width: viewBox.size.width * scale.width, height: viewBox.size.height * scale.height)
			
			let xTranslation = (targetSize.width - newSize.width) / 2.0
			let yTranslation = (targetSize.height - newSize.height) / 2.0
			
			return CGPoint(x: xTranslation, y: yTranslation)
			
		case .ScaleAspectFill:
			let scaleFactor = max(targetSize.width / viewBox.size.width, targetSize.height / viewBox.size.height)
			let scale = CGSize(width: scaleFactor, height: scaleFactor)
			
			newSize = CGSize(width: viewBox.size.width * scale.width, height: viewBox.size.height * scale.height)
			
			let xTranslation = (targetSize.width - newSize.width) / 2.0
			let yTranslation = (targetSize.height - newSize.height) / 2.0
			
			return CGPoint(x: xTranslation, y: yTranslation)
			
		case .ScaleToFill:
			newSize = targetSize
			
			//??? WTF
			//let scaleFactor = CGSize(width: bounds.width / targetSize.width, height: bounds.height / targetSize.height)
			
			return CGPoint.zero
			
		case .Center:
			let xTranslation = (targetSize.width - viewBox.size.width) / 2.0
			let yTranslation = (targetSize.height - viewBox.size.height) / 2.0
			
			return CGPoint(x: xTranslation, y: yTranslation)
			
		default:
			return CGPoint.zero
		}
	}
	
	public func isPermittedContentElement(element: SVGElement) -> Bool {
		switch element {
		case _ as SVGAnimationElement: fallthrough
		case _ as SVGDescriptiveElement: fallthrough
		case _ as SVGShapeElement: fallthrough
		case _ as SVGStructuralElement: fallthrough
		case _ as SVGGradientElement:
			return true
			
		default:
			return false
		}
		//<a>, <altGlyphDef>, <clipPath>, <color-profile>, <cursor>, <filter>, <font>, <font-face>, <foreignObject>, <image>, <marker>, <mask>, <pattern>, <script>, <style>, <switch>, <text>, <view>
	}
}
