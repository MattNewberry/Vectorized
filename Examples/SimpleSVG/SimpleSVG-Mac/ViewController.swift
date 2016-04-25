//
//  ViewController.swift
//  SimpleSVG
//
//  Created by Brian Christensen on 4/24/16.
//  Copyright © 2016 Alien Orb Software LLC. All rights reserved.
//

import Cocoa
import Vectorized

class ViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		(view as! SVGView).contentMode = .ScaleAspectFit
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

