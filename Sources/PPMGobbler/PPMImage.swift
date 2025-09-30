//
//  PPMImage.swift
//  PPMGobbler
//
//  Created by syan on 25/08/2025.
//

import Foundation

public struct PPMImage<T: PPMPixel>: Sendable, Hashable, CustomStringConvertible {
    // MARK: Properties
    public var width: Int
    public var height: Int
    private(set) public var pixels: [T]
    
    // MARK: Init
    public init(width: Int, height: Int, pixels: [T]) throws(PPMError) {
        self.width = width
        self.height = height
        self.pixels = pixels
        guard width * height == pixels.count else {
            throw PPMError.mismatchWidthHeightAndContent
        }
    }
    
    public init(width: Int, height: Int, pixel: T) {
        self.width = width
        self.height = height
        self.pixels = Array(repeating: pixel, count: width * height)
    }
    
    public init<U: PPMPixel>(image: PPMImage<U>) {
        self.width = image.width
        self.height = image.height
        self.pixels = image.pixels.map { T.init($0) }
    }
    
    public init(data: Data) throws(PPMError) {
        let parsed = try PPMFile(data: data)
        
        switch parsed.format {
        case .P1, .P4:
            let pixels: [T] = parsed.pixels
                .map { (value: UInt16) in
                    let doubleValue: Double = value > 0 ? 0 : 1
                    return T(r: doubleValue, g: doubleValue, b: doubleValue)
                }
            
            try self.init(width: Int(parsed.width), height: Int(parsed.height), pixels: pixels)
            
        case .P2, .P5:
            let pixels: [T] = parsed.pixels
                .map { (value: UInt16) in
                    let doubleValue: Double = Double(value) / Double(parsed.levels)
                    return T(r: doubleValue, g: doubleValue, b: doubleValue)
                }
            
            try self.init(width: Int(parsed.width), height: Int(parsed.height), pixels: pixels)
            
        case .P3, .P6:
            let pixels: [T] = parsed.pixels
                .split(subsequenceSize: 3)
                .map { (values: [UInt16]) in
                    let rValue: Double = Double(values[0]) / Double(parsed.levels)
                    let gValue: Double = Double(values[1]) / Double(parsed.levels)
                    let bValue: Double = Double(values[2]) / Double(parsed.levels)
                    return T(r: rValue, g: gValue, b: bValue)
                }
            
            try self.init(width: Int(parsed.width), height: Int(parsed.height), pixels: pixels)
        }
    }
    
    public func data(format: PPMFormat, levels requiredLevels: UInt16? = nil) throws(PPMError) -> Data {
        let levels = requiredLevels ?? format.defaultLevels
        let doubleLevels = Double(levels)

        var pixels = [UInt16]()
        pixels.reserveCapacity(width * height * Int(format.numberOfComponents))

        switch format {
        case .P1, .P4:
            pixels = self.pixels.map {
                PPMPixelBW($0).value ? 0 : 1
            }
            
        case .P2, .P5:
            pixels = self.pixels.map {
                UInt16((PPMPixelGrey($0).value * doubleLevels).rounded())
            }
            
        case .P3, .P6:
            pixels = self.pixels.map {
                let p = PPMPixelRGB($0)
                return [
                    UInt16((p.r * doubleLevels).rounded()),
                    UInt16((p.g * doubleLevels).rounded()),
                    UInt16((p.b * doubleLevels).rounded())
                ]
            }.reduce([], +)
            
        }
        
        return try PPMFile(format: format, width: UInt(width), height: UInt(height), levels: levels, pixels: pixels).data
    }
    
    // MARK: Pixels access
    public subscript(x: Int, y: Int) -> T {
        get { return pixels[y * width + x] }
        set { pixels[y * width + x] = newValue }
    }
    
    public func row(_ row: Int) -> [T] {
        return Array(pixels[row * width ..< (row + 1) * width])
    }
    
    public func col(_ col: Int) -> [T] {
        return (0..<height).map { y in pixels[y * width + col] }
    }
    
    // MARK: Helpers
    public var description: String {
        return "PPImage(\(T.name), \(width)x\(height))"
    }
}
