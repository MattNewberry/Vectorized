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

// Enumeration defining the possible XML tags in an SVG file
private enum ElementName: String {
	case SVG = "svg"
}

internal class NuParser: NSObject, NSXMLParserDelegate {
	internal var parserError: ErrorType?

	private var xmlParser: NSXMLParser
	private var elementStack: [SVGElement] = []
	private var documents: [SVGDocument] = []

	/// Initializes an SVGParser for the file at the given path
	///
	/// :param: path The path to the SVG file
	/// :returns: An SVGParser ready to parse()
	internal convenience init?(path: String) {
		if path.isEmpty {
			return nil
		}
		
		let url = NSURL(fileURLWithPath: path)
		
		if let parser = NSXMLParser(contentsOfURL: url) {
			self.init(parser: parser)
			return
		}
		
		return nil
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
	
	internal func parse() throws -> [SVGDocument] {
		if xmlParser.parse() {
			if let error = parserError {
				throw error
			}
			
			return documents
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
			switch name {
			case .SVG:
				let document = try SVGDocument(attributes: attributes)
				elementStack.append(document)
				documents.append(document)
			}
		}
	}
	
	private func endElement(name: String) throws {
		if let _ = ElementName(rawValue: name.lowercaseString) {
			elementStack.removeLast()
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
		abortParsingWithError(parseError)
	}
}
