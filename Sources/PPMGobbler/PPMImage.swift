//
//  PPMImage.swift
//  PPMGobbler
//
//  Created by syan on 25/08/2025.
//

import Foundation

public struct PPMImage<T: PPMPixel>: Sendable, Hashable, CustomStringConvertible {
    // MARK: Properties
    public var width: UInt
    public var height: UInt
    private(set) internal var data: [[T]]
    
    // MARK: Init
    public init(width: UInt, height: UInt, data: [[T]]) throws(PPMError) {
        self.width = width
        self.height = height
        self.data = data
        guard height == data.count else {
            throw PPMError.mismatchWidthHeightAndContent
        }
        for row in data {
            guard width == row.count else {
                throw PPMError.mismatchWidthHeightAndContent
            }
        }
    }
    
    public init(width: UInt, height: UInt, pixel: T) {
        self.width = width
        self.height = height
        self.data = Array(repeating: Array(repeating: pixel, count: Int(width)), count: Int(height))
    }
    
    public init<U: PPMPixel>(image: PPMImage<U>) {
        self.width = image.width
        self.height = image.height
        self.data = image.data.map { row in
            row.map { T.init($0) }
        }
    }
    
    public init(data: Data) throws(PPMError) {
        let parsed = try PPMFile(data: data)
        
        switch parsed.format {
        case .P1, .P4:
            let pixels: [[T]] = parsed.pixels
                .map { (value: UInt16) in
                    let doubleValue: Double = value > 0 ? 0 : 1
                    return T(r: doubleValue, g: doubleValue, b: doubleValue)
                }
                .split(subsequenceSize: Int(parsed.width))
            
            try self.init(width: parsed.width, height: parsed.height, data: pixels)
            
        case .P2, .P5:
            let pixels: [[T]] = parsed.pixels
                .map { (value: UInt16) in
                    let doubleValue: Double = Double(value) / Double(parsed.levels)
                    return T(r: doubleValue, g: doubleValue, b: doubleValue)
                }
                .split(subsequenceSize: Int(parsed.width))
            
            try self.init(width: parsed.width, height: parsed.height, data: pixels)
            
        case .P3, .P6:
            let pixels: [[T]] = parsed.pixels
                .split(subsequenceSize: 3)
                .map { (values: [UInt16]) in
                    let rValue: Double = Double(values[0]) / Double(parsed.levels)
                    let gValue: Double = Double(values[1]) / Double(parsed.levels)
                    let bValue: Double = Double(values[2]) / Double(parsed.levels)
                    return T(r: rValue, g: gValue, b: bValue)
                }
                .split(subsequenceSize: Int(parsed.width))
            
            try self.init(width: parsed.width, height: parsed.height, data: pixels)
        }
    }
    
    public func data(format: PPMFormat, levels requiredLevels: UInt16? = nil) -> Data {
        let levels = requiredLevels ?? format.defaultLevels
        let doubleLevels = Double(levels)

        var pixels = [UInt16]()
        pixels.reserveCapacity(Int(width * height * format.numberOfComponents))

        switch format {
        case .P1, .P4:
            pixels = data.map { row in
                row.map {
                    PPMPixelBW($0).value ? 0 : 1
                }
            }.reduce([], +)
            
        case .P2, .P5:
            pixels = data.map { row in
                row.map {
                    UInt16((PPMPixelGrey($0).value * doubleLevels).rounded())
                }
            }.reduce([], +)
            
        case .P3, .P6:
            pixels = data.map { row in
                row.map {
                    let p = PPMPixelRGB($0)
                    return [
                        UInt16((p.r * doubleLevels).rounded()),
                        UInt16((p.g * doubleLevels).rounded()),
                        UInt16((p.b * doubleLevels).rounded())
                    ]
                }.reduce([], +)
            }.reduce([], +)
            
        }
        
        return PPMFile(format: format, width: width, height: height, levels: levels, pixels: pixels).data
    }
    
    // MARK: Pixels access
    public subscript(x: UInt, y: UInt) -> T {
        get { return data[Int(y)][Int(x)] }
        set { data[Int(y)][Int(x)] = newValue }
    }
    
    public func row(_ row: UInt) -> [T] {
        return data[Int(row)]
    }
    
    public func col(_ col: UInt) -> [T] {
        return data.map { $0[Int(col)] }
    }
    
    // MARK: Helpers
    public var description: String {
        return "PPImage(\(T.name), \(width)x\(height))"
    }
}
