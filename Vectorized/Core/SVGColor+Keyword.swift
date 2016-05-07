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

import Foundation

public extension SVGColor {
	public convenience init?(keyword rawKeyword: String) {
		if let keyword = SVGColorKeyword(rawValue: rawKeyword) {
			self.init(keyword: keyword)
			return
		}
		
		self.init() // https://bugs.swift.org/browse/SR-704
		return nil
	}
	
	public convenience init?(keyword: SVGColorKeyword) {
		if let rgb = _colorKeywordTable[keyword] {
			self.init(red: rgb.0, green: rgb.1, blue: rgb.2)
			return
		}
		
		self.init() // https://bugs.swift.org/browse/SR-704
		return nil
	}
}

// http://www.w3.org/TR/SVG/types.html#ColorKeywords
public enum SVGColorKeyword: String {
	case AliceBlue = "aliceblue"
	case AntiqueWhite = "antiquewhite"
	case Aqua = "aqua"
	case AquaMarine = "aquamarine"
	case Azure = "azure"
	case Beige = "beige"
	case Bisque = "bisque"
	case Black = "black"
	case BlanchedAlmond = "blanchedalmond"
	case Blue = "blue"
	case BlueViolet = "blueviolet"
	case Brown = "brown"
	case Burlywood = "burlywood"
	case CadetBlue = "cadetblue"
	case Chartreuse = "chartreuse"
	case Chocolate = "chocolate"
	case Coral = "coral"
	case CornflowerBlue = "cornflowerblue"
	case CornSilk = "cornsilk"
	case Crimson = "crimson"
	case Cyan = "cyan"
	case DarkBlue = "darkblue"
	case DarkCyan = "darkcyan"
	case DarkGoldenrod = "darkgoldenrod"
	case DarkGray = "darkgray"
	case DarkGreen = "darkgreen"
	case DarkGrey = "darkgrey"
	case DarkKhaki = "darkkhaki"
	case DarkMagenta = "darkmagenta"
	case DarkOliveGreen = "darkolivegreen"
	case DarkOrange = "darkorange"
	case DarkOrchid = "darkorchid"
	case DarkRed = "darkred"
	case DarkSalmon = "darksalmon"
	case DarkSeaGreen = "darkseagreen"
	case DarkSlateBlue = "darkslateblue"
	case DarkSlateGray = "darkslategray"
	case DarkSlateGrey = "darkslategrey"
	case DarkTurquoise = "darkturquoise"
	case DarkViolet = "darkviolet"
	case DeepPink = "deeppink"
	case DeepskyBlue = "deepskyblue"
	case DimGray = "dimgray"
	case DimGrey = "dimgrey"
	case DodgerBlue = "dodgerblue"
	case Firebrick = "firebrick"
	case FloralWhite = "floralwhite"
	case ForestGreen = "forestgreen"
	case Fuchsia = "fuchsia"
	case Gainsboro = "gainsboro"
	case GhostWhite = "ghostwhite"
	case Gold = "gold"
	case Goldenrod = "goldenrod"
	case Gray = "gray"
	case Grey = "grey"
	case Green = "green"
	case GreenYellow = "greenyellow"
	case Honeydew = "honeydew"
	case HotPink = "hotpink"
	case IndianRed = "indianred"
	case Indigo = "indigo"
	case Ivory = "ivory"
	case Khaki = "khaki"
	case Lavender = "lavender"
	case LavenderBlush = "lavenderblush"
	case LawnGreen = "lawngreen"
	case LemonChiffon = "lemonchiffon"
	case LightBlue = "lightblue"
	case LightCoral = "lightcoral"
	case LightCyan = "lightcyan"
	case LightGoldenrodYellow = "lightgoldenrodyellow"
	case LightGray = "lightgray"
	case LightGreen = "lightgreen"
	case LightGrey = "lightgrey"
	case LightPink = "lightpink"
	case LightSalmon = "lightsalmon"
	case LightSeaGreen = "lightseagreen"
	case LightSkyBlue = "lightskyblue"
	case LightSlateGray = "lightslategray"
	case LightSlateGrey = "lightslategrey"
	case LightSteelBlue = "lightsteelblue"
	case LightYellow = "lightyellow"
	case Lime = "lime"
	case LimeGreen = "limegreen"
	case Linen = "linen"
	case Magenta = "magenta"
	case Maroon = "maroon"
	case MediumAquamarine = "mediumaquamarine"
	case MediumBlue = "mediumblue"
	case MediumOrchid = "mediumorchid"
	case MediumPurple = "mediumpurple"
	case MediumSeaGreen = "mediumseagreen"
	case MediumSlateBlue = "mediumslateblue"
	case MediumSpringGreen = "mediumspringgreen"
	case MediumTurquoise = "mediumturquoise"
	case MediumVioletRed = "mediumvioletred"
	case MidnightBlue = "midnightblue"
	case MintCream = "mintcream"
	case MistyRose = "mistyrose"
	case Moccasin = "moccasin"
	case NavajoWhite = "navajowhite"
	case Navy = "navy"
	case OldLace = "oldlace"
	case Olive = "olive"
	case OliveDrab = "olivedrab"
	case Orange = "orange"
	case OrangeRed = "orangered"
	case Orchid = "orchid"
	case PaleGoldenrod = "palegoldenrod"
	case PaleGreen = "palegreen"
	case PaleTurquoise = "paleturquoise"
	case PaleVioletRed = "palevioletred"
	case Papayawhip = "papayawhip"
	case PeachPuff = "peachpuff"
	case Peru = "peru"
	case Pink = "pink"
	case Plum = "plum"
	case PowderBlue = "powderblue"
	case Purple = "purple"
	case Red = "red"
	case Rosybrown = "rosybrown"
	case RoyalBlue = "royalblue"
	case Saddlebrown = "saddlebrown"
	case Salmon = "salmon"
	case SandyBrown = "sandybrown"
	case SeaGreen = "seagreen"
	case Seashell = "seashell"
	case Sienna = "sienna"
	case Silver = "silver"
	case SkyBlue = "skyblue"
	case SlateBlue = "slateblue"
	case SlateGray = "slategray"
	case SlateGrey = "slategrey"
	case Snow = "snow"
	case SpringGreen = "springgreen"
	case SteelBlue = "steelblue"
	case Tan = "tan"
	case Teal = "teal"
	case Thistle = "thistle"
	case Tomato = "tomato"
	case Turquoise = "turquoise"
	case Violet = "violet"
	case Wheat = "wheat"
	case White = "white"
	case Whitesmoke = "whitesmoke"
	case Yellow = "yellow"
	case YellowGreen = "yellowgreen"
}

private let _colorKeywordTable: [SVGColorKeyword : (Int, Int, Int)] = [
	.AliceBlue : (240, 248, 255),
	.AntiqueWhite : (250, 235, 215),
	.Aqua : (0, 255, 255),
	.AquaMarine : (127, 255, 212),
	.Azure : (240, 255, 255),
	.Beige : (245, 245, 220),
	.Bisque : (255, 228, 196),
	.Black : (0, 0, 0),
	.BlanchedAlmond : (255, 235, 205),
	.Blue : (0, 0, 255),
	.BlueViolet : (138, 43, 226),
	.Brown : (165, 42, 42),
	.Burlywood : (222, 184, 135),
	.CadetBlue : (95, 158, 160),
	.Chartreuse : (127, 255, 0),
	.Chocolate : (210, 105, 30),
	.Coral : (255, 127, 80),
	.CornflowerBlue : (100, 149, 237),
	.CornSilk : (255, 248, 220),
	.Crimson : (220, 20, 60),
	.Cyan : (0, 255, 255),
	.DarkBlue : (0, 0, 139),
	.DarkCyan : (0, 139, 139),
	.DarkGoldenrod : (184, 134, 11),
	.DarkGray : (169, 169, 169),
	.DarkGreen : (0, 100, 0),
	.DarkGrey : (169, 169, 169),
	.DarkKhaki : (189, 183, 107),
	.DarkMagenta : (139, 0, 139),
	.DarkOliveGreen : (85, 107, 47),
	.DarkOrange : (255, 140, 0),
	.DarkOrchid : (153, 50, 204),
	.DarkRed : (139, 0, 0),
	.DarkSalmon : (233, 150, 122),
	.DarkSeaGreen : (143, 188, 143),
	.DarkSlateBlue : (72, 61, 139),
	.DarkSlateGray : (47, 79, 79),
	.DarkSlateGrey : (47, 79, 79),
	.DarkTurquoise : (0, 206, 209),
	.DarkViolet : (148, 0, 211),
	.DeepPink : (255, 20, 147),
	.DeepskyBlue : (0, 191, 255),
	.DimGray : (105, 105, 105),
	.DimGrey : (105, 105, 105),
	.DodgerBlue : (30, 144, 255),
	.Firebrick : (178, 34, 34),
	.FloralWhite : (255, 250, 240),
	.ForestGreen : (34, 139, 34),
	.Fuchsia : (255, 0, 255),
	.Gainsboro : (220, 220, 220),
	.GhostWhite : (248, 248, 255),
	.Gold : (255, 215, 0),
	.Goldenrod : (218, 165, 32),
	.Gray : (128, 128, 128),
	.Grey : (128, 128, 128),
	.Green : (0, 128, 0),
	.GreenYellow : (173, 255, 47),
	.Honeydew : (240, 255, 240),
	.HotPink : (255, 105, 180),
	.IndianRed : (205, 92, 92),
	.Indigo : (75, 0, 130),
	.Ivory : (255, 255, 240),
	.Khaki : (240, 230, 140),
	.Lavender : (230, 230, 250),
	.LavenderBlush : (255, 240, 245),
	.LawnGreen : (124, 252, 0),
	.LemonChiffon : (255, 250, 205),
	.LightBlue : (173, 216, 230),
	.LightCoral : (240, 128, 128),
	.LightCyan : (224, 255, 255),
	.LightGoldenrodYellow : (250, 250, 210),
	.LightGray : (211, 211, 211),
	.LightGreen : (144, 238, 144),
	.LightGrey : (211, 211, 211),
	.LightPink : (255, 182, 193),
	.LightSalmon : (255, 160, 122),
	.LightSeaGreen : (32, 178, 170),
	.LightSkyBlue : (135, 206, 250),
	.LightSlateGray : (119, 136, 153),
	.LightSlateGrey : (119, 136, 153),
	.LightSteelBlue : (176, 196, 222),
	.LightYellow : (255, 255, 224),
	.Lime : (0, 255, 0),
	.LimeGreen : (50, 205, 50),
	.Linen : (250, 240, 230),
	.Magenta : (255, 0, 255),
	.Maroon : (128, 0, 0),
	.MediumAquamarine : (102, 205, 170),
	.MediumBlue : (0, 0, 205),
	.MediumOrchid : (186, 85, 211),
	.MediumPurple : (147, 112, 219),
	.MediumSeaGreen : (60, 179, 113),
	.MediumSlateBlue : (123, 104, 238),
	.MediumSpringGreen : (0, 250, 154),
	.MediumTurquoise : (72, 209, 204),
	.MediumVioletRed : (199, 21, 133),
	.MidnightBlue : (25, 25, 112),
	.MintCream : (245, 255, 250),
	.MistyRose : (255, 228, 225),
	.Moccasin : (255, 228, 181),
	.NavajoWhite : (255, 222, 173),
	.Navy : (0, 0, 128),
	.OldLace : (253, 245, 230),
	.Olive : (128, 128, 0),
	.OliveDrab : (107, 142, 35),
	.Orange : (255, 165, 0),
	.OrangeRed : (255, 69, 0),
	.Orchid : (218, 112, 214),
	.PaleGoldenrod : (238, 232, 170),
	.PaleGreen : (152, 251, 152),
	.PaleTurquoise : (175, 238, 238),
	.PaleVioletRed : (219, 112, 147),
	.Papayawhip : (255, 239, 213),
	.PeachPuff : (255, 218, 185),
	.Peru : (205, 133, 63),
	.Pink : (255, 192, 203),
	.Plum : (221, 160, 221),
	.PowderBlue : (176, 224, 230),
	.Purple : (128, 0, 128),
	.Red : (255, 0, 0),
	.Rosybrown : (188, 143, 143),
	.RoyalBlue : (65, 105, 225),
	.Saddlebrown : (139, 69, 19),
	.Salmon : (250, 128, 114),
	.SandyBrown : (244, 164, 96),
	.SeaGreen : (46, 139, 87),
	.Seashell : (255, 245, 238),
	.Sienna : (160, 82, 45),
	.Silver : (192, 192, 192),
	.SkyBlue : (135, 206, 235),
	.SlateBlue : (106, 90, 205),
	.SlateGray : (112, 128, 144),
	.SlateGrey : (112, 128, 144),
	.Snow : (255, 250, 250),
	.SpringGreen : (0, 255, 127),
	.SteelBlue : (70, 130, 180),
	.Tan : (210, 180, 140),
	.Teal : (0, 128, 128),
	.Thistle : (216, 191, 216),
	.Tomato : (255, 99, 71),
	.Turquoise : (64, 224, 208),
	.Violet : (238, 130, 238),
	.Wheat : (245, 222, 179),
	.White : (255, 255, 255),
	.Whitesmoke : (245, 245, 245),
	.Yellow : (255, 255, 0),
	.YellowGreen : (154, 205, 50)
]
