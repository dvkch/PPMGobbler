//
//  PPMImage+CGImage.swift
//  PPMGobbler
//
//  Created by syan on 27/08/2025.
//

#if canImport(CoreGraphics)
import Foundation
import CoreGraphics

// MARK: Native image conversions
public extension PPMImage {
    var cgImage: CoreGraphics.CGImage? {
        let components: Int
        let colorspace: CGColorSpace
        let bitmapInfo: CGBitmapInfo
        let pixels: [UInt8]

        if T.self == PPMPixelRGB.self {
            components = 4
            colorspace = CGColorSpaceCreateDeviceRGB()
            bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)
            pixels = data
                .reduce([], +)
                .flatMap { pixel in
                    let r = UInt8(max(0, min(255, pixel.r * 255)))
                    let g = UInt8(max(0, min(255, pixel.g * 255)))
                    let b = UInt8(max(0, min(255, pixel.b * 255)))
                    return [r, g, b, 255]
                }
        }
        else if T.self == PPMPixelGrey.self || T.self == PPMPixelBW.self {
            components = 1
            colorspace = CGColorSpaceCreateDeviceGray()
            bitmapInfo = CGBitmapInfo(rawValue: 0)
            pixels = data
                .reduce([], +)
                .map { pixel in
                    return UInt8(max(0, min(255, pixel.r * 255)))
                }
        }
        else {
            fatalError("Unsupported pixel format")
        }

        let providerRef = CGDataProvider(data: Data(pixels) as CFData)!
        return CGImage(
            width: Int(width),
            height: Int(height),
            bitsPerComponent: 8,
            bitsPerPixel: 8 * components,
            bytesPerRow: components * Int(width),
            space: colorspace,
            bitmapInfo: bitmapInfo,
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
    }
}
#endif
