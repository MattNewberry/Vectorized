# Vectorized

[![Release](https://img.shields.io/badge/release-under%20development-red.svg)](https://github.com/alienorb/Vectorized/releases)
[![Platform](https://img.shields.io/badge/platform-mac%20%7C%20ios-lightgrey.svg)](https://github.com/alienorb/Vectorized)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/alienorb/Vectorized/blob/master/LICENSE)

Vectorized is a native Swift framework for parsing and displaying SVG files in your Mac or iOS applications.

Vectorized is a derivative fork of [SwiftVG](https://github.com/austinfitzpatrick/SwiftVG), an excellent framework originally written by Austin Fitzpatrick. The core architecture remains roughly the same, but amongst several changes, Vectorized contains modifications to make the code cross-platform across Mac and iOS, a Swift port of Arthur Evstifeev's immensely useful [SKUBezierPath+SVG](https://github.com/ap4y/UIBezierPath-SVG) code, as well as a suite of unit tests to ensure the robustness of the parser.

## Installing

### Carthage

To integrate Vectorized into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify the following in your `Cartfile`:

```ogdl
github "alienorb/Vectorized"
```

## License

The MIT License (MIT)

Copyright (c) 2012 Arthur Evstifeev (UIBezierPath-SVG/SKUBezierPath+SVG)  
Copyright (c) 2014 Michael Redig (UIBezierPath-SVG/SKUBezierPath+SVG)  
Copyright (c) 2015 Austin Fitzpatrick (the "SwiftVG" project)  
Copyright (c) 2015 Seedling (the "SwiftVG" project)  
Copyright (c) 2016 Alien Orb Software LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
