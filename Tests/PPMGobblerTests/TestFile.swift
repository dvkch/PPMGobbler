//
//  TestFile.swift
//  PPMGobbler
//
//  Created by syan on 25/08/2025.
//

import Foundation
@testable import PPMGobbler

struct TestFile: Sendable, CustomStringConvertible {
    var format: PPMFormat
    var levels: UInt16
    var variants: [String] = []
    
    private func filename(variant: String?) -> String {
        let variantPart = variant.map { "_\($0)" } ?? ""
        return "test_\(format.rawValue.lowercased())_\(levels)\(variantPart).\(format.fileExtension)"
    }
    
    static let orignalURL = Bundle.module.url(forResource: "sample", withExtension: "png", subdirectory: "Resources")!.absoluteURL

    var url: URL {
        TestFile.orignalURL.deletingLastPathComponent().appending(path: filename(variant: nil)).absoluteURL
    }
    
    func variantURL(for variant: String) -> URL {
        TestFile.orignalURL.deletingLastPathComponent().appending(path: filename(variant: variant)).absoluteURL
    }
    
    var description: String {
        filename(variant: nil)
    }
}

extension TestFile {
    static let allCases: [TestFile] = [
        .init(format: .P1, levels:      1, variants: ["no_blank", "comments"]),
        .init(format: .P2, levels:    255, variants: ["no_blank", "comments"]),
        .init(format: .P2, levels: 10_000),
        .init(format: .P2, levels: 65_535),
        .init(format: .P3, levels:    255, variants: ["no_blank", "comments"]),
        .init(format: .P3, levels: 10_000),
        .init(format: .P3, levels: 65_535),
        .init(format: .P4, levels:      1),
        .init(format: .P5, levels:    255),
        .init(format: .P5, levels: 10_000),
        .init(format: .P5, levels: 65_535),
        .init(format: .P6, levels:    255),
        .init(format: .P6, levels: 10_000),
        .init(format: .P6, levels: 65_535),
    ]
    
    static var inMemory: PPMImage<PPMPixelRGB> {
        let red     = PPMPixelRGB(r: 1.00, g: 0.00, b: 0.00)
        let orange  = PPMPixelRGB(r: 1.00, g: 0.50, b: 0.00)
        let yellow  = PPMPixelRGB(r: 1.00, g: 1.00, b: 0.00)
        let green   = PPMPixelRGB(r: 0.00, g: 1.00, b: 0.00)
        let blue    = PPMPixelRGB(r: 0.00, g: 0.00, b: 1.00)
        let purple  = PPMPixelRGB(r: 0.75, g: 0.00, b: 0.75)
        let black   = PPMPixelRGB(r: 0.00, g: 0.00, b: 0.00)
        let white   = PPMPixelRGB(r: 1.00, g: 1.00, b: 1.00)
        let gray80  = PPMPixelRGB(r: 0.80, g: 0.80, b: 0.80)
        
        return try! .init(width: 7, height: 9, pixels: [
            red,    orange, yellow, green,  blue,   purple, black,
            white,  red,    orange, yellow, green,  blue,   purple,
            black,  white,  red,    orange, yellow, green,  blue,
            purple, black,  white,  red,    orange, yellow, green,
            blue,   purple, black,  white,  red,    orange, yellow,
            green,  blue,   purple, black,  white,  red,    orange,
            yellow, green,  blue,   purple, black,  white,  red,
            orange, yellow, green,  blue,   purple, black,  white,
            gray80, gray80, gray80, gray80, gray80, gray80, gray80,
        ])
    }
}
