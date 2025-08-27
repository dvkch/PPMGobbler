//
//  PPMImage+NSImage.swift
//  PPMGobbler
//
//  Created by syan on 27/08/2025.
//

#if os(macOS)
import Foundation
import AppKit

// MARK: Native image conversions
public extension PPMImage {
    var nsImage: AppKit.NSImage? {
        guard let cgImage = self.cgImage else { return nil }
        return NSImage(cgImage: cgImage, size: NSSize(width: CGFloat(width), height: CGFloat(height)))
    }
}
#endif
