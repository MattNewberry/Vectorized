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

internal protocol SVGElementParsing: SVGElement {
	init(parseAttributes: [String : String], location: (Int, Int)?) throws
	
	func parseAttribute(name: String, value: String, location: (Int, Int)?) throws -> SVGAttribute?
	func processParsedAttributes(attributes: [String : SVGAttribute], location: (Int, Int)?) throws -> [String : SVGAttribute]
	func endElement() throws
}

private enum AttributeName: String {
	case X = "x"
	case Y = "y"
	case Width = "width"
	case Height = "height"
	case RadiusX = "rx"
	case RadiusY = "ry"
	case ViewBox = "viewBox"
	case Transform = "transform"
}

internal extension SVGElementParsing {
	init(parseAttributes attributes: [String : String], location: (Int, Int)?) throws {
		self.init()
		
		var parsedAttributes: [String : SVGAttribute] = [:]
		
		for attribute in attributes {
			if let parsed = try parseAttribute(attribute.0, value: attribute.1, location: location) {
				parsedAttributes[attribute.0] = parsed
			}
		}

		if !attributes.isEmpty {
			parsedAttributes = try processParsedAttributes(attributesByProcessingCommon(parsedAttributes), location: location)
		}
		
		self.attributes = parsedAttributes
	}
	
	func parseAttribute(name: String, value: String, location: (Int, Int)?) throws -> SVGAttribute? {
		var attribute: SVGAttribute?

		if let attributeName = AttributeName(rawValue: name) {
			switch attributeName {
			case .X: fallthrough
			case .Y: fallthrough
			case .Width: fallthrough
			case .Height: fallthrough
			case .RadiusX: fallthrough
			case .RadiusY:
				attribute = try SVGLength(parseValue: value, location: location)
				
			case .ViewBox:
				attribute = try CGRect(parseValue: value, location: location)
				
			case .Transform:
				break
			}
		}
		
		return attribute
	}
	
	private func attributesByProcessingCommon(attributes: [String : SVGAttribute]) -> [String : SVGAttribute] {
		var processedAttributes: [String : SVGAttribute] = attributes
		
		var position: SVGPoint?
		
		let x = processedAttributes["x"] as? SVGLength
		let y = processedAttributes["y"] as? SVGLength
		
		if x != nil || y != nil {
			position = SVGPoint(x: x ?? SVGLengthZero, y: y ?? SVGLengthZero)
		}
		
		processedAttributes["position"] = position
		
		var size: SVGSize?
		
		let width = processedAttributes["width"] as? SVGLength
		let height = processedAttributes["height"] as? SVGLength
		
		if width != nil || height != nil {
			size = SVGSize(width: width ?? SVGLengthZero, height: height ?? SVGLengthZero)
		}
		
		processedAttributes["size"] = size
		
		let rx = processedAttributes["rx"] as? SVGLength
		let ry = processedAttributes["ry"] as? SVGLength
		
		if rx != nil || ry != nil {
			processedAttributes["rx"] = rx ?? ry
			processedAttributes["ry"] = ry ?? rx
		}
		
		return processedAttributes
	}
	
	func processParsedAttributes(attributes: [String : SVGAttribute], location: (Int, Int)?) throws -> [String : SVGAttribute] {
		return attributes
	}
	
	func endElement() throws {}
}
