//---------------------------------------------------------------------------------------
//	The MIT License (MIT)
//
//	Based on parser code by Austin Fitzpatrick (the "SwiftVG" project)
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

internal class SVGParser: NSObject, NSXMLParserDelegate {
	internal var parserError: ErrorType?
	internal var line: Int { return xmlParser.lineNumber }
	internal var column: Int { return xmlParser.columnNumber }
	internal var mode: ParseMode = .WarnsUnhandled
	internal var filename: String?

	internal enum ParseMode {
		case IgnoresUnhandled
		case WarnsUnhandled
		case ThrowsUnhandled
	}
	
	// Enumeration defining the possible XML tags in an SVG file
	private enum ElementName: String {
		case Document = "svg"
		case Group = "g"
		case Rect = "rect"
	}
	
	private var xmlParser: NSXMLParser
	private var elementStack: [SVGElement] = []
	private var root: SVGDocument?
	private var foundRoot: Bool = false
	
	internal class func sanitizedValue(parseValue: String?) -> String? {
		guard let parseValue = parseValue else { return nil }
		
		let value = parseValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		
		if value.isEmpty {
			return nil
		}
		
		return value
	}

	internal convenience init(path: String) throws {
		if path.isEmpty {
			throw SVGError.InvalidDocumentPath(path)
		}
		
		let url = NSURL(fileURLWithPath: path)
		
		if let parser = NSXMLParser(contentsOfURL: url) {
			self.init(parser: parser)
			
			filename = url.pathComponents?.last
			
			return
		}

		throw SVGError.UnknownParserFailure
	}
	
	internal convenience init(data: NSData) {
		self.init(parser: NSXMLParser(data: data))
	}
	
	private init(parser: NSXMLParser) {
		xmlParser = parser
		super.init()
		xmlParser.delegate = self
	}
	
	private func abortParsingWithError(error: ErrorType) {
		parserError = error
		xmlParser.abortParsing()
	}
	
	internal func parse() throws -> SVGDocument {
		if xmlParser.parse() {
			if let error = parserError {
				throw error
			}
			
			if let root = root {
				return root
			}
			
			parserError = SVGError.NoRootDocumentFound
			throw parserError!
		}
		
		if let error = parserError {
			throw error
		}
		
		if let error = xmlParser.parserError {
			parserError = SVGError.NSXMLParserError(error)
			throw parserError!
		}
		
		parserError = SVGError.UnknownParserFailure
		throw parserError!
	}
	
	private func beginElement(name: String, withAttributes attributes: [String : String]) throws {
		if let name = ElementName(rawValue: name.lowercaseString) {
			try parseElement(name, withAttributes: attributes)
		} else {
			if mode == .WarnsUnhandled {
				print("{SVGParser: \(filename ?? "")<\(line)::\(column)>}: Unhandled element: \(name)")
			} else if mode == .ThrowsUnhandled {
				throw SVGError.UnhandledElement(name, location: (line, column))
			}
		}
	}
	
	private func parseElement(name: ElementName, withAttributes attributes: [String : String]) throws {
		var element: SVGElement
		
		switch name {
		case .Document:
			element = try SVGDocument(parseAttributes: attributes, parser: self)
			foundRoot = true
			
		case .Group:
			element = try SVGGroup(parseAttributes: attributes, parser: self)
			
		case .Rect:
			element = try SVGRect(parseAttributes: attributes, parser: self)
		}

		elementStack.append(element)
	}
	
	private func endElement(name: String) throws {
		if let _ = ElementName(rawValue: name.lowercaseString) {
			if elementStack.count == 1 {
				if let document = elementStack.last as? SVGDocument {
					root = document
					return
				} else {
					
				}
			}
			
			if let top = elementStack.last {
				elementStack.removeLast()
				
				if var parent = elementStack.last {
					if parent.appendChild(top) {
						elementStack.removeLast()
						elementStack.append(parent)
					} else {
						throw SVGError.UnpermittedContentElement(name, location: (line, column), message: nil)
					}
				}
			}
		}
	}

	// MARK: -
	// MARK: NSXMLParserDelegate
	
	@objc internal func parserDidStartDocument(parser: NSXMLParser) {
		
	}
	
	@objc internal func parserDidEndDocument(parser: NSXMLParser) {
		
	}
	
	@objc internal func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
		do {
			try beginElement(elementName, withAttributes: attributeDict)
		} catch {
			abortParsingWithError(error)
		}
	}
	
	@objc internal func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		do {
			try endElement(elementName)
		} catch {
			abortParsingWithError(error)
		}
	}
	
	@objc internal func parser(parser: NSXMLParser, foundCharacters string: String) {
		
	}
	
	@objc internal func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
		//abortParsingWithError(parseError)
	}
}
