//
//  PPMPixel.swift
//  PPMGobbler
//
//  Created by syan on 25/08/2025.
//

import Foundation

public protocol PPMPixel: Sendable, Hashable {
    static var name: String { get }
    init(r: Double, g: Double, b: Double)
    init(_ pixel: any PPMPixel)
    var r: Double { get }
    var g: Double { get }
    var b: Double { get }
}

public struct PPMPixelRGB: PPMPixel {
    public static var name: String { "RGB" }
    public init(r: Double, g: Double, b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }
    public init(_ pixel: any PPMPixel) {
        self.init(r: pixel.r, g: pixel.g, b: pixel.b)
    }
    public var r: Double
    public var g: Double
    public var b: Double
}

public struct PPMPixelGrey: PPMPixel {
    public static var name: String { "Grey" }
    public init(_ value: Double) {
        self.value = value
    }
    public init(r: Double, g: Double, b: Double) {
        self.value = 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    public init(_ pixel: any PPMPixel) {
        self.init(r: pixel.r, g: pixel.g, b: pixel.b)
    }
    public var value: Double
    public var r: Double { value }
    public var g: Double { value }
    public var b: Double { value }
}

public struct PPMPixelBW: PPMPixel {
    public static var name: String { "BW" }
    public init(_ value: Bool) {
        self.value = value
    }
    public init(r: Double, g: Double, b: Double) {
        self.value = 0.2126 * r + 0.7152 * g + 0.0722 * b >= 0.5
    }
    public init(_ pixel: any PPMPixel) {
        self.init(r: pixel.r, g: pixel.g, b: pixel.b)
    }
    public var value: Bool
    public var r: Double { value ? 1 : 0 }
    public var g: Double { value ? 1 : 0 }
    public var b: Double { value ? 1 : 0 }
}
