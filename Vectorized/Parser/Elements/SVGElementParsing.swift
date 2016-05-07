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

internal protocol SVGElementParsing: SVGElement {
	init(parseAttributes: [String : String], parser: SVGParser?) throws
	
	func parseAttribute(name: SVGAttributeName, value: String, location: (Int, Int)?) throws -> SVGAttribute?
	func processParsedAttributes(attributes: [SVGAttributeName : SVGAttribute], location: (Int, Int)?) throws -> [SVGAttributeName : SVGAttribute]
	func endElement() throws
}

private var _combinedAttributeParsers: [SVGCombinedAttributeParsing.Type] = [
	SVGPoint.self,
	SVGSize.self,
	SVGLength.self,
	SVGStroke.self,
	SVGFill.self
]

internal extension SVGElementParsing {
	init(parseAttributes attributes: [String : String], parser: SVGParser?) throws {
		self.init()
		
		let location: (Int, Int)? = parser != nil ? (parser!.line, parser!.column) : nil
		var remainingAttributes = try convertedAttributes(attributes, parser: parser)
		var parsedAttributes: [SVGAttributeName : SVGAttribute] = [:]
		
		for parser in _combinedAttributeParsers {
			if remainingAttributes.isEmpty {
				break
			}
			
			if let (resultingAttributes, removableKeys) = try parser.parseAttributes(remainingAttributes, location: location) {
				for attribute in resultingAttributes {
					parsedAttributes[attribute.0] = attribute.1
				}
				
				for removeKey in removableKeys {
					remainingAttributes[removeKey] = nil
				}
			}
		}
		
		for attribute in remainingAttributes {
			if let parsed = try parseAttribute(attribute.0, value: attribute.1, location: location) {
				parsedAttributes[attribute.0] = parsed
			}
		}
		
		if !attributes.isEmpty {
			parsedAttributes = try processParsedAttributes(parsedAttributes, location: location)
		}
		
		self.attributes = parsedAttributes
	}
	
	func convertedAttributes(attributes: [String : String], parser: SVGParser?) throws -> [SVGAttributeName : String] {
		var convertedAttributes: [SVGAttributeName : String] = [:]
		
		for attribute in attributes {
			if let attributeName = SVGAttributeName(rawValue: attribute.0) {
				convertedAttributes[attributeName] = attribute.1
			} else if let parser = parser {
				if parser.mode == .WarnsUnhandled {
					print("\t{SVGParser: \(parser.filename ?? "")<\(parser.line)::\(parser.column)>}: Unhandled attribute: \(attribute.0)")
				} else if parser.mode == .ThrowsUnhandled {
					throw SVGError.UnhandledAttribute(attribute.0, location: (parser.line, parser.column))
				}
			}
		}
		
		return convertedAttributes
	}

	func parseAttribute(name: SVGAttributeName, value: String, location: (Int, Int)?) throws -> SVGAttribute? {
		var attribute: SVGAttribute?

		switch name {
		case .ID:
			attribute = SVGParser.sanitizedValue(value)
		
		case .Version:
			attribute = SVGParser.sanitizedValue(value)
		
		case .ViewBox:
			attribute = try CGRect(parseValue: value, location: location)
			
		case .Transform:
			attribute = try SVGTransform(parseValue: value, location: location)
			
		default:
			throw SVGError.UnhandledAttribute(name.rawValue, location: location)
		}
		
		return attribute
	}
	
	func processParsedAttributes(attributes: [SVGAttributeName : SVGAttribute], location: (Int, Int)?) throws -> [SVGAttributeName : SVGAttribute] {
		return attributes
	}

	func endElement() throws {}
}
