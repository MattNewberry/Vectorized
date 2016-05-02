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

extension SVGTransform: SVGAttributeParsing {
	init?(parseValue: String?, location: (Int, Int)? = nil) throws {
		guard let value = SVGParser.sanitizedValue(parseValue) else { return nil }
		
		self.init(transforms: try SVGTransform.transformFromString(value))
	}

	private static func transformFromString(transformString: String?) throws -> [CGAffineTransform] {
		var transforms: [(CGAffineTransform, Int)] = []

		if let string = transformString {
			let scanner = NSScanner(string: string, skipCommas: true)
			
			func parseType(type: String, parser: ((NSScanner) throws -> CGAffineTransform?)) throws -> Int {
				if scanner.scanString(type, intoString: nil) {
					if let transform = try parser(scanner) {
						transforms.append((transform, scanner.scanLocation))
					}
					
					return 1
				}
				
				return 0
			}
			
			while !scanner.atEnd {
				var matches = 0
				
				matches += try parseType("matrix", parser: parseTransformMatrix)
				matches += try parseType("translate", parser: parseTransformTranslate)
				matches += try parseType("scale", parser: parseTransformScale)
				matches += try parseType("rotate", parser: parseTransformRotate)
				
				if matches == 0 {
					scanner.scanLocation += 1
				}
			}
			
			transforms.sortInPlace {
				return $0.1 > $1.1		// apply from right to left
			}
		}
		
		return transforms.map {
			return $0.0
		}
	}
	
	private static func parseTransformMatrix(scanner: NSScanner) throws -> CGAffineTransform? {
		if !scanner.scanString("(", intoString: nil) {
			throw SVGError.MissingOpeningBrace("matrix")
		}
		
		var a: Float = 0, b: Float = 0, c: Float = 0, d: Float = 0, tx: Float = 0, ty: Float = 0
		
		if !scanner.scanFloat(&a) {
			throw SVGError.InvalidTransformDefinition("matrix", error: "Missing <a>")
		}
		
		if !scanner.scanFloat(&b) {
			throw SVGError.InvalidTransformDefinition("matrix", error: "Missing <b>")
		}
		
		if !scanner.scanFloat(&c) {
			throw SVGError.InvalidTransformDefinition("matrix", error: "Missing <c>")
		}
		
		if !scanner.scanFloat(&d) {
			throw SVGError.InvalidTransformDefinition("matrix", error: "Missing <d>")
		}
		
		if !scanner.scanFloat(&tx) {
			throw SVGError.InvalidTransformDefinition("matrix", error: "Missing <e>")
		}
		
		if !scanner.scanFloat(&ty) {
			throw SVGError.InvalidTransformDefinition("matrix", error: "Missing <f>")
		}
		
		if !scanner.scanString(")", intoString: nil) {
			throw SVGError.MissingClosingBrace("matrix")
		}
		
		return CGAffineTransform(a: CGFloat(a), b: CGFloat(b), c: CGFloat(c), d: CGFloat(d), tx: CGFloat(tx), ty: CGFloat(ty))
	}
	
	private static func parseTransformTranslate(scanner: NSScanner) throws -> CGAffineTransform? {
		if !scanner.scanString("(", intoString: nil) {
			throw SVGError.MissingOpeningBrace("translate")
		}
		
		var x: Float = 0, y: Float = 0
		
		if !scanner.scanFloat(&x) {
			throw SVGError.InvalidTransformDefinition("translate", error: "Missing <x>")
		}
		
		// y is optional
		scanner.scanFloat(&y)
		
		if !scanner.scanString(")", intoString: nil) {
			throw SVGError.MissingClosingBrace("translate")
		}
		
		return CGAffineTransformMakeTranslation(CGFloat(x), CGFloat(y))
	}
	
	private static func parseTransformScale(scanner: NSScanner) throws -> CGAffineTransform? {
		if !scanner.scanString("(", intoString: nil) {
			throw SVGError.MissingOpeningBrace("translate")
		}
		
		var x: Float = 0, y: Float = 0
		
		if !scanner.scanFloat(&x) {
			throw SVGError.InvalidTransformDefinition("scale", error: "Missing <x>")
		}
		
		// y is optional
		scanner.scanFloat(&y)
		
		if !scanner.scanString(")", intoString: nil) {
			throw SVGError.MissingClosingBrace("scale")
		}
		
		return CGAffineTransformMakeScale(CGFloat(x), CGFloat(y))
	}
	
	private static func parseTransformRotate(scanner: NSScanner) throws -> CGAffineTransform? {
		var transform: CGAffineTransform
		
		if !scanner.scanString("(", intoString: nil) {
			throw SVGError.MissingOpeningBrace("translate")
		}
		
		var angle: Float = 0, x: Float = 0, y: Float = 0
		
		if !scanner.scanFloat(&angle) {
			throw SVGError.InvalidTransformDefinition("rotate", error: "Missing <a>")
		}
		
		// [x, y] pair is optional
		if scanner.scanFloat(&x) {
			if !scanner.scanFloat(&y) {
				throw SVGError.InvalidTransformDefinition("rotate", error: "Missing <y> to go with <x>")
			}
		}
		
		if !scanner.scanString(")", intoString: nil) {
			throw SVGError.MissingClosingBrace("scale")
		}
		
		transform = CGAffineTransformMakeTranslation(CGFloat(x), CGFloat(y))
		transform = CGAffineTransformRotate(transform, CGFloat(angle))
		transform = CGAffineTransformTranslate(transform, CGFloat(-x), CGFloat(-y))
		
		return transform
	}
}
