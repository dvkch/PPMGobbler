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
    init(cgImage: CoreGraphics.CGImage) throws(PPMError) {
        let components: Int
        let colorspace: CGColorSpace
        let bitmapInfo: CGBitmapInfo

        if T.self == PPMPixelRGB.self {
            components = 4
            colorspace = CGColorSpaceCreateDeviceRGB()
            bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        }
        else if T.self == PPMPixelGrey.self || T.self == PPMPixelBW.self {
            components = 1
            colorspace = CGColorSpaceCreateDeviceGray()
            bitmapInfo = CGBitmapInfo(rawValue: 0)
        }
        else {
            throw PPMError.unsupportedPixelType
        }
        
        var rawPixels = [UInt8](repeating: 0, count: Int(cgImage.height * cgImage.width * components))
        rawPixels.withUnsafeMutableBytes { ptr in
            if let context = CGContext(
                data: ptr.baseAddress,
                width: cgImage.width,
                height: cgImage.height,
                bitsPerComponent: 8,
                bytesPerRow: cgImage.width * components,
                space: colorspace,
                bitmapInfo: bitmapInfo.rawValue
            ) {
                let rect = CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height)
                context.draw(cgImage, in: rect)
            }
        }
        
        let pixels: [T]
        switch components {
        case 1:
            pixels = rawPixels
                .map { T(r: Double($0) / 255, g: Double($0) / 255, b: Double($0) / 255) }
        case 4:
            pixels = rawPixels
                .split(subsequenceSize: 4)
                .map { T(r: Double($0[0]) / 255, g: Double($0[1]) / 255, b: Double($0[2]) / 255) }
            
        default:
            throw PPMError.unsupportedPixelType
        }
        
        try self.init(width: cgImage.width, height: cgImage.height, pixels: pixels)
    }

    func cgImage() throws(PPMError) -> CoreGraphics.CGImage {
        let components: Int
        let colorspace: CGColorSpace
        let bitmapInfo: CGBitmapInfo
        let pixels: [UInt8]

        if T.self == PPMPixelRGB.self {
            components = 4
            colorspace = CGColorSpaceCreateDeviceRGB()
            bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)
            pixels = self.pixels.flatMap { pixel in
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
            pixels = self.pixels.map { pixel in
                return UInt8(max(0, min(255, pixel.r * 255)))
            }
        }
        else {
            throw PPMError.unsupportedPixelType
        }

        let providerRef = CGDataProvider(data: Data(pixels) as CFData)!
        let image = CGImage(
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
        guard let image else {
            throw PPMError.cannotGenerateCGImage
        }
        return image
    }
}
#endif
