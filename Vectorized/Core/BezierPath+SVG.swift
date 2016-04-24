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

import X
import Foundation

private enum CommandType: Int {
	case Absolute
	case Relative
}

private protocol SVGCommand {
	func processCommandString(commandString: String, withPrevCommand: String, forPath: BezierPathType, factoryIdentifier: String)
}

private class SVGCommandImpl: SVGCommand {
	static var paramRegex = try! NSRegularExpression(pattern: "[-+]?[0-9]*\\.?[0-9]+", options: [])
	
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
	
	func processCommandString(commandString: String, withPrevCommand prevCommand: String, forPath path: BezierPathType, factoryIdentifier identifier: String) {
		self.prevCommand = prevCommand
		
		let commandLetter = commandString.substringToIndex(commandString.startIndex.advancedBy(1))
		let params = parametersForCommand(commandString)
		let commandType: CommandType = isAbsoluteCommand(commandLetter) ? .Absolute : .Relative
		
		performWithParams(params, commandType: commandType, forPath: path, factoryIdentifier: identifier)
	}
	
	func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: BezierPathType, factoryIdentifier identifier: String) {
		fatalError("You must override \(#function) in a subclass")
	}
}

private class SVGMoveCommand: SVGCommandImpl {
	override func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: BezierPathType, factoryIdentifier identifier: String) {
		if type == .Absolute {
			path.moveToPoint(CGPoint(x: params[0], y: params[1]))
		} else {
			path.moveToPoint(CGPoint(x: path.currentPoint.x + params[0], y: path.currentPoint.y + params[1]))
		}
	}
}

private class SVGLineToCommand: SVGCommandImpl {
	override func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: BezierPathType, factoryIdentifier identifier: String) {
		if type == .Absolute {
			path.addLineToPoint(CGPoint(x: params[0], y: params[1]))
		} else {
			path.addLineToPoint(CGPoint(x: path.currentPoint.x + params[0], y: path.currentPoint.y + params[1]))
		}
	}
}

private class SVGHorizontalLineToCommand: SVGCommandImpl {
	override func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: BezierPathType, factoryIdentifier identifier: String) {
		if type == .Absolute {
			path.addLineToPoint(CGPoint(x: params[0], y: path.currentPoint.y))
		} else {
			path.addLineToPoint(CGPoint(x: path.currentPoint.x + params[0], y: path.currentPoint.y))
		}
	}
}

private class SVGVerticalLineToCommand: SVGCommandImpl {
	override func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: BezierPathType, factoryIdentifier identifier: String) {
		if type == .Absolute {
			path.addLineToPoint(CGPoint(x: path.currentPoint.x, y: params[0]))
		} else {
			path.addLineToPoint(CGPoint(x: path.currentPoint.x, y: path.currentPoint.y + params[0]))
		}
	}
}

private class SVGCurveToCommand: SVGCommandImpl {
	override func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: BezierPathType, factoryIdentifier identifier: String) {
		if type == .Absolute {
			path.addCurveToPoint(CGPoint(x: params[4], y: params[5]), controlPoint1: CGPoint(x: params[0], y: params[1]), controlPoint2: CGPoint(x: params[2], y: params[3]))
		} else {
			path.addCurveToPoint(CGPoint(x: path.currentPoint.x + params[4], y: path.currentPoint.y + params[5]), controlPoint1: CGPoint(x: path.currentPoint.x + params[0], y: path.currentPoint.y + params[1]), controlPoint2: CGPoint(x: path.currentPoint.x + params[2], y: path.currentPoint.y + params[3]))
		}
	}
}

private class SVGSmoothCurveToCommand: SVGCommandImpl {
	override func performWithParams(params: [CGFloat], commandType type: CommandType, forPath path: BezierPathType, factoryIdentifier identifier: String) {
		var firstControlPoint = CGPoint(x: path.currentPoint.x, y: path.currentPoint.y)
		
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

public extension BezierPathType {
	public convenience init(SVGString: String, factoryIdentifier: String) {
		self.init()
		
		
	}
	
/*	public func addPathFromSVGString(SVGString: String, factoryIdentifier: String) {
		_ = addPathWithSVGString
	}
	
	private func addPathWithSVGString(SVGString: String, toPath: BezierPathType, factoryIdentifier: String) -> BezierPathType {
		
	}*/
	
	public func addPathWithSVGString(SVGString: String, factoryIdentifier: String) {
		//guard SVGString.length > 0 else { return }
		
		//let regex = commandRegex
	}
}
