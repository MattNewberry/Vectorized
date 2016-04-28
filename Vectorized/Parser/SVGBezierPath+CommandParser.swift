//---------------------------------------------------------------------------------------
//  The MIT License (MIT)
//
//  Created by Arthur Evstifeev on 5/29/12.
//	Modified by Michael Redig 9/28/14
//	Ported to Swift by Brian Christensen <brian@alienorb.com>
//
//  Copyright (c) 2012 Arthur Evstifeev
//	Copyright (c) 2014 Michael Redig
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

import Foundation

public enum SVGError: ErrorType {
	case InvalidCommand(String)
	case UnknownCommand(String)
}

internal extension SVGBezierPath {
	private static let commandRegex = try! NSRegularExpression(pattern: "[A-Za-z]", options: [])
	
	private class func processCommandString(commandString: String, withPrevCommandString prevCommand: String, forPath path: SVGBezierPath, withFactoryIdentifier identifier: String) throws {
		guard commandString.characters.count > 0 else {
			throw SVGError.InvalidCommand(commandString)
		}
		
		let commandLetter = commandString.substringToIndex(commandString.startIndex.advancedBy(1))
		
		if let command = SVGPathCommandFactory.factoryWithIdentifier(identifier).commandForCommandLetter(commandLetter) {
			command.processCommandString(commandString, withPrevCommand: prevCommand, forPath: path, factoryIdentifier: identifier)
		} else {
			throw SVGError.UnknownCommand(commandLetter)
		}
	}
	
	internal class func addPathWithSVGString(SVGString: String, toPath path: SVGBezierPath, factoryIdentifier identifier: String) {
		guard SVGString.characters.count > 0 else { return }
		
		var prevMatch: NSTextCheckingResult?
		var prevCommand = ""
		
		commandRegex.enumerateMatchesInString(SVGString, options: [], range: NSMakeRange(0, SVGString.characters.count)) { (match, flags, stop) in
			if let match = match {
				if let prevMatchUnwrapped = prevMatch {
					let length = match.range.location - prevMatchUnwrapped.range.location
					let commandString = (SVGString as NSString).substringWithRange(NSMakeRange(prevMatchUnwrapped.range.location, length))
					
					do {
						try processCommandString(commandString, withPrevCommandString: prevCommand, forPath: path, withFactoryIdentifier: identifier)
					} catch let error {
						print("SVG parsing failed: \(error)")
					}
					
					prevCommand = commandString
				}
			}
			
			prevMatch = match
		}
		
		if let prevMatch = prevMatch {
			let result = (SVGString as NSString).substringWithRange(NSMakeRange(prevMatch.range.location, SVGString.characters.count - prevMatch.range.location))
			
			do {
				try processCommandString(result, withPrevCommandString: prevCommand, forPath: path, withFactoryIdentifier: identifier)
			} catch let error {
				print("SVG parsing failed: \(error)")
			}
		}
	}
}

