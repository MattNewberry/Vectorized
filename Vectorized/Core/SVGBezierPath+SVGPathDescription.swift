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

public extension SVGBezierPath {
	public convenience init(SVGPathDescription: String, factoryIdentifier identifier: String = "") {
		self.init()
		
		addPathWithSVGPathDescription(SVGPathDescription, factoryIdentifier: identifier)
	}
	
	public func addPathWithSVGPathDescription(description: String, factoryIdentifier identifier: String = "") {
		SVGBezierPath.addPathWithSVGString(description, toPath: self, factoryIdentifier: identifier)
	}
}
