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
