//---------------------------------------------------------------------------------------
//  The MIT License (MIT)
//
//  Created by Arthur Evstifeev on 5/29/12.
//	Modified by Michael Redig 9/28/14
//	Ported to Swift by Brian Christensen <brian@alienorb.com> 4/24/16
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

private enum CommandType: Int {
	case Absolute
	case Relative
}

private protocol SVGCommand {
	func processCommandString(commandString: String, withPrevCommand: String, forPath: SVGBezierPath, factoryIdentifier: String)
}

private class SVGCommandImpl: SVGCommand {
	static let paramRegex = try! NSRegularExpression(pattern: "[-+]?[0-9]*\\.?[0-9]+", options: [])
	
	var prevCommand: String?
	
	func parametersForCommand(commandString: String) -> [CGFloat] {
		let matches = SVGCommandImpl.paramRegex.matchesInString(commandString, options: [], range: NSRange(location: 0, length: commandString.characters.count))
		var results: [CGFloat] = []
		
		for match in matches {
			let paramString = (commandString as NSString).substringWithRange(match.range)
			
			if let value = Float(paramString) {
				results.append(CGFloat(value))
			}
		}
		
		return results
	}
	
	func isAbsoluteCommand(commandLetter: String) -> Bool {
		return commandLetter == commandLetter.uppercaseString
	}
	
	func processCommandString(commandString: String, withPrevCommand prevCommand: String, forPath path: SVGBezierPath, factoryIdentifier identifier: String) {
		self.prevCommand = prevCommand
		
		let commandLetter = commandString.substringToIndex(commandString.startIndex.advancedBy(1))
		let params = parametersForCommand(commandString)
		let commandType: CommandType = isAbsoluteCommand(commandLetter) ? .Absolute : .Relative
		
		performWithParams(params, commandType: commandType, forPath: path, factoryIdentifier: identifier)
	}
	
	func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: SVGBezierPath, factoryIdentifier identifier: String) {
		fatalError("You must override \(#function) in a subclass")
	}
}

private class SVGMoveCommand: SVGCommandImpl {
	override func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: SVGBezierPath, factoryIdentifier identifier: String) {
		if type == .Absolute {
			path.moveToPoint(CGPoint(x: params[0], y: params[1]))
		} else {
			path.moveToPoint(CGPoint(x: path.currentPoint.x + params[0], y: path.currentPoint.y + params[1]))
		}
	}
}

private class SVGLineToCommand: SVGCommandImpl {
	override func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: SVGBezierPath, factoryIdentifier identifier: String) {
		if type == .Absolute {
			path.addLineToPoint(CGPoint(x: params[0], y: params[1]))
		} else {
			path.addLineToPoint(CGPoint(x: path.currentPoint.x + params[0], y: path.currentPoint.y + params[1]))
		}
	}
}

private class SVGHorizontalLineToCommand: SVGCommandImpl {
	override func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: SVGBezierPath, factoryIdentifier identifier: String) {
		if type == .Absolute {
			path.addLineToPoint(CGPoint(x: params[0], y: path.currentPoint.y))
		} else {
			path.addLineToPoint(CGPoint(x: path.currentPoint.x + params[0], y: path.currentPoint.y))
		}
	}
}

private class SVGVerticalLineToCommand: SVGCommandImpl {
	override func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: SVGBezierPath, factoryIdentifier identifier: String) {
		if type == .Absolute {
			path.addLineToPoint(CGPoint(x: path.currentPoint.x, y: params[0]))
		} else {
			path.addLineToPoint(CGPoint(x: path.currentPoint.x, y: path.currentPoint.y + params[0]))
		}
	}
}

private class SVGCurveToCommand: SVGCommandImpl {
	override func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: SVGBezierPath, factoryIdentifier identifier: String) {
		if type == .Absolute {
			path.addCurveToPoint(CGPoint(x: params[4], y: params[5]), controlPoint1: CGPoint(x: params[0], y: params[1]), controlPoint2: CGPoint(x: params[2], y: params[3]))
		} else {
			path.addCurveToPoint(CGPoint(x: path.currentPoint.x + params[4], y: path.currentPoint.y + params[5]), controlPoint1: CGPoint(x: path.currentPoint.x + params[0], y: path.currentPoint.y + params[1]), controlPoint2: CGPoint(x: path.currentPoint.x + params[2], y: path.currentPoint.y + params[3]))
		}
	}
}

private class SVGSmoothCurveToCommand: SVGCommandImpl {
	override func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: SVGBezierPath, factoryIdentifier identifier: String) {
		var firstControlPoint = path.currentPoint
		
		if let prevCommand = prevCommand {
			if prevCommand.characters.count > 0 {
				let prevCommandType = prevCommand.substringToIndex(prevCommand.startIndex.advancedBy(1))
				let prevCommandTypeLowercase = prevCommandType.lowercaseString
				let isAbsolute = prevCommandType != prevCommandTypeLowercase
				
				if prevCommandTypeLowercase == "c" || prevCommandTypeLowercase == "s" {
					let prevParams = parametersForCommand(prevCommand)
					
					if prevCommandTypeLowercase == "c" {
						if isAbsolute {
							firstControlPoint = CGPoint(x: -1 * prevParams[2] + 2 * path.currentPoint.x, y: -1 * prevParams[3] + 2 * path.currentPoint.y)
						} else {
							let oldCurrentPoint = CGPoint(x: path.currentPoint.x - prevParams[4], y: path.currentPoint.y - prevParams[5])
							
							firstControlPoint = CGPoint(x: -1 * (prevParams[2] + oldCurrentPoint.x) + 2 * path.currentPoint.x, y: -1 * (prevParams[3] + oldCurrentPoint.y) + 2 * path.currentPoint.y)
						}
					} else {
						if isAbsolute {
							firstControlPoint = CGPoint(x: -1 * prevParams[0] + 2 * path.currentPoint.x, y: -1 * prevParams[1] + 2 * path.currentPoint.y)
						} else {
							let oldCurrentPoint = CGPoint(x: path.currentPoint.x - prevParams[2], y: path.currentPoint.y - prevParams[3])
							
							firstControlPoint = CGPoint(x: -1 * (prevParams[0] + oldCurrentPoint.x) + 2 * path.currentPoint.x, y: -1 * (prevParams[1] + oldCurrentPoint.y) + 2 * path.currentPoint.y)
						}
					}
				}
			}
		}
		
		if type == .Absolute {
			path.addCurveToPoint(CGPoint(x: params[2], y: params[3]), controlPoint1: CGPoint(x: firstControlPoint.x, y: firstControlPoint.y), controlPoint2: CGPoint(x: params[0], y: params[1]))
		} else {
			path.addCurveToPoint(CGPoint(x: path.currentPoint.x + params[2], y: path.currentPoint.y + params[3]), controlPoint1: CGPoint(x: firstControlPoint.x, y: firstControlPoint.y), controlPoint2: CGPoint(x: path.currentPoint.x + params[0], y: path.currentPoint.y + params[1]))
		}
	}
}

private class SVGQuadraticCurveToCommand: SVGCommandImpl {
	override func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: SVGBezierPath, factoryIdentifier identifier: String) {
		if type == .Absolute {
			path.addQuadCurveToPoint(CGPoint(x: params[2], y: params[3]), controlPoint: CGPoint(x: params[0], y: params[1]))
		} else {
			path.addQuadCurveToPoint(CGPoint(x: path.currentPoint.x + params[2], y: path.currentPoint.y + params[3]), controlPoint: CGPoint(x: path.currentPoint.x + params[0], y: path.currentPoint.y + params[1]))
		}
	}
}

private class SVGSmoothQuadraticCurveToCommand: SVGCommandImpl {
	override func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: SVGBezierPath, factoryIdentifier identifier: String) {
		var firstControlPoint = path.currentPoint
		
		if let prevCommand = prevCommand {
			if prevCommand.characters.count > 0 {
				let prevCommandType = prevCommand.substringToIndex(prevCommand.startIndex.advancedBy(1))
				let prevCommandTypeLowercase = prevCommandType.lowercaseString
				let isAbsolute = prevCommandType != prevCommandTypeLowercase
				
				if prevCommandTypeLowercase == "q" {
					let prevParams = parametersForCommand(prevCommand)
					
					if isAbsolute {
						firstControlPoint = CGPoint(x: -1 * prevParams[0] + 2 * path.currentPoint.x, y: -1 * prevParams[1] + 2 * path.currentPoint.y)
					} else {
						let oldCurrentPoint = CGPoint(x: path.currentPoint.x - prevParams[2], y: path.currentPoint.y - prevParams[3])
						
						firstControlPoint = CGPoint(x: -1 * (prevParams[0] + oldCurrentPoint.x) + 2 * path.currentPoint.x, y: -1 * (prevParams[1] + oldCurrentPoint.y) + 2 * path.currentPoint.y)
					}
				}
			}
		}
		
		if type == .Absolute {
			path.addQuadCurveToPoint(CGPoint(x: params[0], y: params[1]), controlPoint: firstControlPoint)
		} else {
			path.addQuadCurveToPoint(CGPoint(x: path.currentPoint.x + params[0], y: path.currentPoint.y + params[1]), controlPoint: firstControlPoint)
		}
	}
}

private class SVGClosePathCommand: SVGCommandImpl {
	override func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: SVGBezierPath, factoryIdentifier identifier: String) {
		path.closePath()
	}
}

private class SVGCommandFactory {
	static let defaultFactory = SVGCommandFactory()
	static var factories: [String: SVGCommandFactory] = [:]
	
	private var commands: [String: SVGCommand] = [:]
	
	class func factoryWithIdentifier(identifier: String) -> SVGCommandFactory {
		if let factory = factories[identifier] {
			return factory
		}
		
		factories[identifier] = SVGCommandFactory()
		
		return factories[identifier]!
	}
	
	init() {
		commands["m"] = SVGMoveCommand()
		commands["l"] = SVGLineToCommand()
		commands["h"] = SVGHorizontalLineToCommand()
		commands["v"] = SVGVerticalLineToCommand()
		commands["c"] = SVGCurveToCommand()
		commands["s"] = SVGSmoothCurveToCommand()
		commands["q"] = SVGQuadraticCurveToCommand()
		commands["t"] = SVGSmoothQuadraticCurveToCommand()
		commands["z"] = SVGClosePathCommand()
	}
	
	func commandForCommandLetter(commandLetter: String) -> SVGCommand? {
		return commands[commandLetter.lowercaseString]
	}
}

public enum SVGError: ErrorType {
	case InvalidCommand(String)
	case UnknownCommand(String)
}

public extension SVGBezierPath {
	private static let commandRegex = try! NSRegularExpression(pattern: "[A-Za-z]", options: [])
	
	private class func processCommandString(commandString: String, withPrevCommandString prevCommand: String, forPath path: SVGBezierPath, withFactoryIdentifier identifier: String) throws {
		guard commandString.characters.count > 0 else {
			throw SVGError.InvalidCommand(commandString)
		}
		
		let commandLetter = commandString.substringToIndex(commandString.startIndex.advancedBy(1))
		
		if let command = SVGCommandFactory.factoryWithIdentifier(identifier).commandForCommandLetter(commandLetter) {
			command.processCommandString(commandString, withPrevCommand: prevCommand, forPath: path, factoryIdentifier: identifier)
		} else {
			throw SVGError.UnknownCommand(commandLetter)
		}
	}
	
	private class func addPathWithSVGString(SVGString: String, toPath path: SVGBezierPath, factoryIdentifier identifier: String) {
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
	
	public convenience init(SVGString: String, factoryIdentifier identifier: String) {
		self.init()
		
		addPathFromSVGString(SVGString, factoryIdentifier: identifier)
	}
	
	public func addPathFromSVGString(SVGString: String, factoryIdentifier identifier: String) {
		SVGBezierPath.addPathWithSVGString(SVGString, toPath: self, factoryIdentifier: identifier)
	}
}
