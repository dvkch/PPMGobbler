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
    init(nsImage: NSImage) throws(PPMError) {
        var rect = NSRect(origin: .zero, size: nsImage.size)
        guard let cgImage = nsImage.cgImage(forProposedRect: &rect, context: nil, hints: nil) else {
            throw PPMError.missingCGImage
        }
        try self.init(cgImage: cgImage)
    }

    func nsImage() throws(PPMError) -> AppKit.NSImage {
        let cgImage = try self.cgImage()
        return NSImage(cgImage: cgImage, size: NSSize(width: CGFloat(width), height: CGFloat(height)))
    }
}
#endif
