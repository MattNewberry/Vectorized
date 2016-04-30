//---------------------------------------------------------------------------------------
//  The MIT License (MIT)
//
//  Created by Austin Fitzpatrick on 3/18/15 (the "SwiftVG" project)
//	Modified by Brian Christensen <brian@alienorb.com>
//
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
import CoreGraphics

/// A Parser which takes in a .svg file and spits out an SVGGraphic for display
/// Begin your interaction with the parser by initializing it with a path and calling
/// parse() to retrieve an SVGGraphic.  Safe to call on a background thread.
internal class SVGParser: NSObject, NSXMLParserDelegate {
	// Enumeration defining the possible XML tags in an SVG file
	enum ElementName: String {
		case SVG = "svg"
		case G = "g"
		case Defs = "defs"
		case Rect = "rect"
		case Use = "use"
		case RadialGradient = "radialGradient"
		case LinearGradient = "linearGradient"
		case Stop = "stop"
		case Path = "path"
		case Polygon = "polygon"
		case ClipPath = "clipPath"
		case Text = "text"
		case Polyline = "polyline"
		case Ellipse = "ellipse"
	}
	
    internal let parserId: String = NSUUID().UUIDString
	
	private var parser: NSXMLParser?
	private var svgViewBox: CGRect = CGRectZero
	private var drawables: [SVGDrawable] = []
	private var colors: [String: SVGColor] = [:]
	private var gradients: [String: SVGGradient] = [:]
	private var namedPaths: [String: SVGBezierPath] = [:]
	private var clippingPaths: [String: SVGBezierPath] = [:]
	private var lastGradient: SVGGradient?
	private var lastGroup: SVGGroup?
	private var lastClippingPath: String?
	private var definingDefs: Bool = false
	private var lastText: SVGText?
	
    /// Initializes an SVGParser for the file at the given path
    ///
    /// :param: path The path to the SVG file
    /// :returns: An SVGParser ready to parse()
    internal init(path: String) {
        let url = NSURL(fileURLWithPath: path)
		
        if let parser = NSXMLParser(contentsOfURL: url) {
            self.parser = parser
        } else {
            fatalError("SVGParser could not find an SVG at the given path: \(path)")
        }
    }
    
    internal init(data: NSData) {
        parser = NSXMLParser(data: data)
    }
    
    /// Parse the supplied SVG file and return an SVGGraphic
    ///
    /// :returns: an SVGImageVector ready for display
    internal func parse() -> SVGGraphic {
        let (drawables, size) = coreParse()
		
        return SVGGraphic(drawables: drawables, size: size)
    }
    
    /// Parse the supplied SVG file and return the components of an SVGGraphic
    ///
    /// :returns: a tuple containing the SVGDrawable array and the size of the SVGGraphic
    internal func coreParse() -> ([SVGDrawable], CGSize) {
        parser?.delegate = self
        parser?.parse()
		
        return (drawables, svgViewBox.size)
    }
    
    /// Parse a transform matrix string "matrix(a,b,c,d,tx,ty)" and return a CGAffineTransform
    ///
    /// :param: string The transformation String
    /// :returns: A CGAffineTransform
    internal class func transformFromString(transformString: String?) -> CGAffineTransform {
        if let string = transformString {
            let scanner = NSScanner(string: string)
			
            scanner.scanString("matrix(", intoString: nil)
			
            var a: Float = 0, b: Float = 0, c: Float = 0, d: Float = 0, tx: Float = 0, ty: Float = 0
			
            scanner.scanFloat(&a)
            scanner.scanFloat(&b)
            scanner.scanFloat(&c)
            scanner.scanFloat(&d)
            scanner.scanFloat(&tx)
            scanner.scanFloat(&ty)
			
            return CGAffineTransform(a: CGFloat(a), b: CGFloat(b), c: CGFloat(c), d: CGFloat(d), tx: CGFloat(tx), ty: CGFloat(ty))
        }
		
		return CGAffineTransformIdentity
    }
	
    /// Takes a string containing a hex value and converts it to a SVGColor.  Caches the SVGColor for later use.
    ///
    /// :param: potentialHexString the string potentially containing a hex value to parse into a SVGColor
    /// :returns: SVGColor representation of the hex string - or nil if no hex string is found
    private func addColor(potentialHexString: String?) -> SVGColor? {
		guard potentialHexString != "none" else { return SVGColor.clearColor() }
		
        if let potentialHexString = potentialHexString {
            if let hexRange = potentialHexString.rangeOfString("#", options: [], range: nil, locale: nil) {
                let hexString = potentialHexString.stringByReplacingCharactersInRange(potentialHexString.startIndex..<hexRange.startIndex, withString: "")
				
                colors[hexString] = colors[hexString] ?? SVGColor(hex: hexString)
				
                return colors[hexString]
            }
        }
		
        return nil
    }
    
    /// Parses a viewBox string and sets the view box of the SVG
    ///
    /// :param: attributeDict the attribute dictionary from the SVG element form which to extract a view box
    private func setViewBox(attributeDict: [String: String]) {
        if let viewBox = attributeDict["viewBox"] {
            let floats: [CGFloat] = viewBox.componentsSeparatedByString(" ").map {
				CGFloat(Float($0) ?? 0.0)
			}
			
            if floats.count < 4 {
				svgViewBox = CGRectZero; print("An error has occured - the view box is zero")
			}
			
            svgViewBox = CGRect(x: floats[0], y: floats[1], width: floats[2], height: floats[3])
        } else {
            let width = Float(attributeDict["width"] ?? "") ?? 0.0
            let height = Float(attributeDict["height"] ?? "") ?? 0.0
			
            svgViewBox = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        }
    }
    
    /// Returns either a gradient ID or hex string for a color from a string (strips "url(" from gradient references)
    ///
    /// :param: string The string to parse for #hexcolors or url(#gradientId)
    /// :returns: A string fit for using as a key to lookup gradients and colors - or nil of the param was nil
    private func itemIDOrHexFromAttribute(string: String?) -> String? {
        let newString = string?.stringByReplacingOccurrencesOfString("url(#", withString: "", options: [], range: nil)
		
        return newString?.stringByReplacingOccurrencesOfString(")", withString: "", options: [], range: nil)
    }
    
    /// Returns an array of points parsed out of a string in the format "x1,y1 x2,y2 x3,y3"
    ///
    /// :params: string the string to parse points out of
    /// :returns: an array of CGPoint structs representing the points in the string
    private func pointsFromPointString(string: String?) -> [CGPoint] {
		guard string != nil else { return [] }
		
        let pairs = string!.componentsSeparatedByString(" ") as [String]
		
        return pairs.filter {
			($0.utf16.count > 0)
		}.map {
			let numbers = $0.componentsSeparatedByString(",")
			let x = Float(numbers[0] ?? "") ?? 0.0
			let y = Float(numbers[1] ?? "") ?? 0.0
			
            return CGPoint(x: CGFloat(x) - self.svgViewBox.origin.x, y: CGFloat(y) - self.svgViewBox.origin.y)
        }
    }
    
    /// Processes a rectangle found during parsing.  If we're defining the <defs> for the document we'll just save the rect
    /// for later use.  If we're not currently defining <defs> then we'll interpret it as a rectangular path.
    ///
    /// :param: attributeDict The attributes from the XML element - currently "x", "y", "width", "height", "id", "opacity", "fill" are supported.
    private func addRect(attributeDict: [String: String]) {
        let id = attributeDict["id"]
		let originX = CGFloat(Float(attributeDict["x"] ?? "") ?? 0.0)
        let originY = CGFloat(Float(attributeDict["y"] ?? "") ?? 0.0)
        let width = CGFloat(Float(attributeDict["width"] ?? "") ?? 0.0)
        let height = CGFloat(Float(attributeDict["height"] ?? "") ?? 0.0)
        let rect = CGRectOffset(CGRect(x: originX, y: originY, width: width, height: height), -svgViewBox.origin.x, -svgViewBox.origin.y)
		
        if definingDefs {
            if let id = id {
                namedPaths[id] = SVGBezierPath(rect: rect)
            } else {
                print("Defining defs, but didn't find id for rect")
            }
        } else {
            let bezierPath = SVGBezierPath(rect: rect)
			
            bezierPath.applyTransform(SVGParser.transformFromString(attributeDict["transform"]))
            createSVGPath(bezierPath, attributeDict: attributeDict)
        }
    }
    
    /// Adds a path defined by attributeDict to either the last group or the root element, if no group exists
    ///
    /// :param: attributeDict The attributes from the XML element - currently "fill", "opacity" and "d" are supported.
    private func addPath(attributeDict: [String: String]) {
        let id = attributeDict["id"]
        let d = attributeDict["d"]!
        let bezierPath = SVGBezierPath(SVGPathDescription: d, factoryIdentifier: parserId)
		
        bezierPath.applyTransform(CGAffineTransformMakeTranslation(-svgViewBox.origin.x, -svgViewBox.origin.y))
        bezierPath.miterLimit = 4
		
        if definingDefs {
            if let id = id {
                namedPaths[id] = bezierPath
            } else {
                print("Defining defs, but didn't find id for rect")
            }
        } else {
            createSVGPath(bezierPath, attributeDict: attributeDict)
        }
    }
    
    /// Adds a path in the shape of the polygon defined by attributeDict
    ///
    /// :param: attributeDict the attributes from the XML - currently "points", "fill", and "opacity"
    private func addPolygon(attributeDict: [String: String]) {
        let id = attributeDict["id"]
        let points = pointsFromPointString(attributeDict["points"])
        let bezierPath = SVGBezierPath()
		
        bezierPath.moveToPoint(points[0])
		
        for i in 1..<points.count {
            bezierPath.addLineToPoint(points[i])
        }
		
        bezierPath.closePath()
		
        if definingDefs {
            if let id = id {
                namedPaths[id] = bezierPath
            } else{
                print("Defining defs, but didn't find id for rect")
            }
        } else {
            createSVGPath(bezierPath, attributeDict: attributeDict)
        }
    }
    
    /// Adds an ellipse defined by the attributes
    ///
    /// :param: attributeDict the attributes defined by the XML
    private func addEllipse(attributeDict: [String: String]){
        let id = attributeDict["id"]
        let centerX = CGFloat(Float(attributeDict["cx"] ?? "") ?? 0.0)
        let centerY = CGFloat(Float(attributeDict["cy"] ?? "") ?? 0.0)
        let radiusX = CGFloat(Float(attributeDict["rx"] ?? "") ?? 0.0)
        let radiusY = CGFloat(Float(attributeDict["ry"] ?? "") ?? 0.0)
//        let rect = CGRectOffset(CGRect(x: centerX - radiusX, y: centerY - radiusY, width: radiusX * 2.0, height: radiusY * 2.0), -svgViewBox.origin.x, -svgViewBox.origin.y)
        let rect = CGRect(x: centerX - radiusX, y: centerY - radiusY, width: radiusX * 2.0, height: radiusY * 2.0)
        let bezierPath = SVGBezierPath(ovalInRect: rect)
		
        if definingDefs {
            if let id = id {
                namedPaths[id] = bezierPath
            } else{
                print("Defining defs, but didn't find id for rect")
            }
        } else {
            bezierPath.applyTransform(SVGParser.transformFromString(attributeDict["transform"]))
            bezierPath.applyTransform(CGAffineTransformMakeTranslation(-svgViewBox.origin.x, -svgViewBox.origin.y))
            createSVGPath(bezierPath, attributeDict: attributeDict)
        }
    }
    
    /// Adds a polyline defined by the attributes
    ///
    /// :param: attributeDict the attributes from the XML - currently "points", "fill", and "opacity"
    private func addPolyline(attributeDict: [String: String]){
        let id = attributeDict["id"]
        let points = pointsFromPointString(attributeDict["points"])
        let bezierPath = SVGBezierPath()
		
        bezierPath.moveToPoint(points[0])
		
        for i in 1..<points.count {
            bezierPath.addLineToPoint(points[i])
        }
		
        //bezierPath.closePath()
		
        if definingDefs {
            if let id = id {
                namedPaths[id] = bezierPath
            } else{
                print("Defining defs, but didn't find id for rect")
            }
        } else {
            createSVGPath(bezierPath, attributeDict: attributeDict)
        }
    }
    
    /// Takes a bezierPath and an attributeDict and inserts the path into the last group
    private func createSVGPath(bezierPath: SVGBezierPath, attributeDict: [String: String]){
        var fill: SVGFillable? = nil
		
        if let attr = itemIDOrHexFromAttribute(attributeDict["fill"]) {
            fill = gradients[attr] ?? addColor(attr)
        }
		
		let opacity = CGFloat(Float(attributeDict["opacity"] ?? "") ?? 1.0)
        let fillRule = attributeDict["fill-rule"] ?? ""
		
        if fillRule == "evenodd" {
            bezierPath.usesEvenOddFillRule = true
        }
		
        var clippingPath: SVGBezierPath?
		
        if let clippingPathName = itemIDOrHexFromAttribute(attributeDict["clip-path"]) {
            clippingPath = clippingPaths[clippingPathName]
        }
		
        let path = SVGPath(bezierPath: bezierPath, fill: fill, opacity: opacity, clippingPath: clippingPath)
		
        path.identifier = attributeDict["id"]
		
        if lastGroup != nil {
            lastGroup?.addToGroup(path)
        } else {
            drawables.append(path)
        }
    }
    
    private func beginText(attributeDict: [String: String]){
        var fill: SVGFillable? = nil
		
        if let attr = itemIDOrHexFromAttribute(attributeDict["fill"]){
            fill = gradients[attr] ?? addColor(attr)
        }
		
        let transform = SVGParser.transformFromString(attributeDict["transform"])
        let text = SVGText()
		
        text.identifier = attributeDict["id"]
        text.transform = transform
        text.fill = fill
        text.viewBox = svgViewBox
		
        if let fontName = attributeDict["font-family"] {
			if let size = Float(attributeDict["font-size"] ?? "") {
				let name = fontName.stringByReplacingOccurrencesOfString("'", withString: "", options: [], range: nil)
				let font = SVGFont(name: name, size: CGFloat(size))
				text.font = font
			}
        }
		
        lastText = text
    }
    
    private func endText(){
        if let lastText = lastText{
            if lastGroup != nil {
                lastGroup?.addToGroup(lastText)
            } else {
                drawables.append(lastText)
            }
        }
		
        lastText = nil
    }
    
    /// Begins a new group, setting "lastGroup" to the newly created group
    private func beginGroup(attributeDict: [String: String]) {
        let newGroup = SVGGroup()
		
        newGroup.identifier = attributeDict["id"]
		
        var clippingPath: SVGBezierPath?
		
        if let clippingPathName = itemIDOrHexFromAttribute(attributeDict["clip-path"]) {
            clippingPath = clippingPaths[clippingPathName]
        }
		
        newGroup.clippingPath = clippingPath
		
        if let lastGroup = lastGroup {
            lastGroup.addToGroup(newGroup)
        }
		
        lastGroup = newGroup
    }
    
    /// Ends the current group and moves "lastGroup" up one level
    private func endGroup() {
        if let last = lastGroup {
            if last.group == nil {
                drawables.append(last)
            }
			
            lastGroup = last.group
        }
    }
    
    /// Begins a new clipping path (we're waiting on "use" at this point)
    private func beginClippingPath(attributeDict: [String: String]) {
        lastClippingPath = attributeDict["id"]
    }
    
    /// Ends the current clipping path
    private func endClippingPath() {
        lastClippingPath = nil
    }
    
    // Adds a use, probably for a clipping path
    private func addUse(attributeDict: [String: String]) {
        if let clippingPath = lastClippingPath {
            if let pathId = ((attributeDict["xlink:href"] ?? attributeDict["href"]))?.stringByReplacingOccurrencesOfString("#", withString: "", options: [], range: nil) {
                clippingPaths[clippingPath] = namedPaths[pathId]
            }
        }
    }
    
    private func addStop(attributeDict: [String: String]) {
        let offset = CGFloat(Float(attributeDict["offset"] ?? "") ?? 0.0)
        
        if let styleAttributes = (attributeDict["style"])?.componentsSeparatedByString(";") {
            var color = SVGColor.blackColor()
            var opacity = CGFloat(1.0)
			
            for styleAttribute in styleAttributes {
                if let colorRange = styleAttribute.rangeOfString("stop-color:", options: .CaseInsensitiveSearch, range: nil, locale: nil){
                    //SET STOP COLOR
                    let range = colorRange.endIndex ..< styleAttribute.endIndex
					
                    color = addColor(styleAttribute.substringWithRange(range)) ?? SVGColor.blackColor()
                } else if let opacityRange = styleAttribute.rangeOfString("stop-opacity:", options: .CaseInsensitiveSearch, range: nil, locale: nil) {
                    //SET STOP OPACITY
                    let range = opacityRange.endIndex ..< styleAttribute.endIndex
					
					opacity = CGFloat(Float(styleAttribute.substringWithRange(range)) ?? 1.0)
                }
            }
			
            lastGradient?.addStop(offset, color: color, opacity: opacity)
        }
    }
    
    //MARK: NSXMLParserDelegate
    
    @objc internal func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        if let elementNameEnum = ElementName(rawValue: elementName) {
            switch elementNameEnum {
            case .SVG:
                setViewBox(attributeDict)
				
            case .RadialGradient:
				lastGradient = SVGRadialGradient(attributeDict: attributeDict, viewBox:svgViewBox)
				
            case .LinearGradient:
				lastGradient = SVGLinearGradient(attributeDict: attributeDict, viewBox:svgViewBox)
				
            case .Stop:
                addStop(attributeDict)
				
            case .Defs:
                definingDefs = true
				
            case .Rect:
                addRect(attributeDict)
				
            case .Path:
                addPath(attributeDict)
				
            case .G:
                beginGroup(attributeDict)
				
            case .Polygon:
                addPolygon(attributeDict)
				
            case .ClipPath:
                beginClippingPath(attributeDict)
				
            case .Use:
                addUse(attributeDict)
				
            case .Text:
                beginText(attributeDict)
				
            case .Polyline:
                addPolyline(attributeDict)
				
            case .Ellipse:
                addEllipse(attributeDict)
				
            //default: break
            }
        }
    }
    
    @objc internal func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let elementNameEnum = ElementName(rawValue: elementName) {
            switch elementNameEnum {
            case .RadialGradient:
                if let gradient = lastGradient {
                    gradients[gradient.id] = gradient
                    lastGradient = nil
                } else {
                    print("We exited a gradient without having a last gradient - something went wrong.")
                }
				
            case .LinearGradient:
                if let gradient = lastGradient {
                    gradients[gradient.id] = gradient
                    lastGradient = nil
                } else {
                    print("We exited a gradient without having a last gradient - something went wrong.")
                }
				
            case .Defs:
                definingDefs = false
				
            case .G:
                endGroup()
				
            case .ClipPath:
                endClippingPath()
				
            case .Text:
                endText()
				
            default: break
            }
        }
    }
    
    @objc internal func parser(parser: NSXMLParser, foundCharacters string: String) {
        lastText?.text = string
    }
	
    @objc internal func parserDidEndDocument(parser: NSXMLParser) {
        parser.delegate = self
        self.parser = nil
    }
}
