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

import Cocoa
import Vectorized
import WebKit

class ViewController: NSViewController {
	@IBOutlet var filePopupButton: NSPopUpButton?
	@IBOutlet var svgView: SVGView?
	@IBOutlet var webView: WebView?
	
	override func viewDidLoad() {
		svgView?.backgroundColor = SVGColor.whiteColor()
		svgView?.contentMode = .ScaleAspectFit
		
		filePopupButton?.removeAllItems()
		
		let paths = NSBundle.mainBundle().URLsForResourcesWithExtension("svg", subdirectory: nil)

		if let names = paths?.map({ $0.lastPathComponent!.stringByReplacingOccurrencesOfString(".svg", withString: "", options: [], range: nil) }) {
			filePopupButton?.addItemsWithTitles(names)
		}
		
		if let recentName = NSUserDefaults.standardUserDefaults().valueForKey("MostRecentTestFileName") as? String {
			filePopupButton?.selectItemWithTitle(recentName)
		} else {
			filePopupButton?.selectItemWithTitle("shapes-rect-01-t")
		}
		
		changePopupSelection(self)
	}
	
	@IBAction func changePopupSelection(sender: AnyObject?) {
		if let name = filePopupButton?.titleOfSelectedItem {
			svgView?.SVGName = name
			webView?.mainFrameURL = NSBundle.mainBundle().URLForResource(name, withExtension: "svg")?.absoluteString
			
			NSUserDefaults.standardUserDefaults().setValue(name, forKey: "MostRecentTestFileName")
		}
	}
}
