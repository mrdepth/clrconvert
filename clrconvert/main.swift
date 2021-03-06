//
//  main.swift
//  clrconvert
//
//  Created by Artem Shimanski on 01.12.16.
//  Copyright © 2016 Artem Shimanski. All rights reserved.
//

import Cocoa

guard CommandLine.arguments.count == 3 else {exit(1)}

extension NSColor {
	public var hexString: String {
		let rgba = UnsafeMutablePointer<CGFloat>.allocate(capacity: 4)
		defer {rgba.deallocate()}
		
		self.getRed(&rgba[0], green: &rgba[1], blue: &rgba[2], alpha: &rgba[3])

		for i in 0..<4 {
			rgba[i] = round(rgba[i] * 255.0)
		}
		return String(format: "0x%02x%02x%02x%02x", Int(rgba[0]), Int(rgba[1]), Int(rgba[2]), Int(rgba[3]))
	};

}

func upperFirstLetter(_ string: String) -> String {
	var s = string
	let r = Range(uncheckedBounds: (lower: s.startIndex, upper: s.index(after: s.startIndex)))
	s.replaceSubrange(r, with: s[r].uppercased())
	return s
}

func lowerFirstLetter(_ string: String) -> String {
	var s = string
	let r = Range(uncheckedBounds: (lower: s.startIndex, upper: s.index(after: s.startIndex)))
	s.replaceSubrange(r, with: s[r].lowercased())
	return s
}

func colorScheme(_ colorList: NSColorList) -> [String:NSColor] {
	var colorScheme = [String: NSColor]()
	for key in colorList.allKeys {
		 colorScheme[upperFirstLetter(key.rawValue)] = colorList.color(withKey: key)!.usingColorSpace(NSColorSpace.sRGB)!
	}
	
	return colorScheme
}

func method(_ colorName: String) -> String {
	return "\tpublic class var \(lowerFirstLetter(colorName)): UIColor {\n" +
		"\t\tget {\n" +
		"\t\t\treturn g_currentScheme![CSColorName.\(upperFirstLetter(colorName)).rawValue]\n" +
		"\t\t}\n\t}\n"
}

func colorCases(_ colorNames: [String]) -> String {
	return colorNames.map { (s) -> String in
		return "\tcase \(upperFirstLetter(s))"
	}.joined(separator: "\n")
}

let input = CommandLine.arguments[1]
let output = CommandLine.arguments[2]
let colorList = NSColorList(name: NSColorList.Name(rawValue: "CS"), fromFile: input)!
let colorSchemeName = upperFirstLetter(URL(fileURLWithPath: input).deletingPathExtension().lastPathComponent)

let cs = colorScheme(colorList)
let colorNames = cs.keys.sorted()

var s = colorNames.map { (s) in
	return method(s)
}

var colorLiterals = [String]()

for key in colorNames {
	var rgba: [CGFloat] = [0,0,0,0]
	cs[key]!.getComponents(&rgba)
	colorLiterals.append("#" + "colorLiteral(red: \(rgba[0]), green: \(rgba[1]), blue: \(rgba[2]), alpha: \(rgba[3]))")
}

let home = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
var template1 = try! String(contentsOf: home.appendingPathComponent("UIColor+CS.swift_"))
var template2 = try! String(contentsOf: home.appendingPathComponent("UIColor+Scheme.swift_"))



template1 = String(format: template1, colorCases(colorNames), colorSchemeName, colorNames.map(method).joined(separator: "\n"))
template2 = String(format: template2, colorSchemeName, colorLiterals.joined(separator: ","))

try! template1.write(to: URL(fileURLWithPath:output).appendingPathComponent("UIColor+CS.swift"), atomically: true, encoding: .utf8)
try! template2.write(to: URL(fileURLWithPath:output).appendingPathComponent("UIColor+\(colorSchemeName).swift"), atomically: true, encoding: .utf8)
