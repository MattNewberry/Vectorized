//---------------------------------------------------------------------------------------
//	The MIT License (MIT)
//
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
	public var attributes: [String : SVGAttribute] = [:]
	
	public var parent: SVGElement?
	public var children: [SVGElement]?
	
	public var version: String? {
		get { return attributes["version"] as? String ?? nil }
	}
	
	public var position: SVGPoint {
		get { return attributes["position"] as? SVGPoint ?? SVGPointZero }
	}
	
	public var size: SVGSize {
		get { return attributes["size"] as? SVGSize ?? SVGSize(width: SVGLength(100, .Percent), height: SVGLength(100, .Percent)) }
	}
	
	public var viewBox: CGRect? {
		get { return attributes["viewBox"] as? CGRect ?? nil }
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
	
	public func draw() {
		CGContextSaveGState(SVGGraphicsGetCurrentContext())
		// draw...
		print("Should draw...")
		CGContextRestoreGState(SVGGraphicsGetCurrentContext())
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
