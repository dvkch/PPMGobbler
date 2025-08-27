//
//  PPMImage+UIImage.swift
//  PPMGobbler
//
//  Created by syan on 27/08/2025.
//

#if canImport(UIKit)
import Foundation
import UIKit

// MARK: Native image conversions
public extension PPMImage {
    init(uiImage: UIImage) throws(PPMError) {
        guard let cgImage = uiImage.cgImage else {
            throw PPMError.missingCGImage
        }
        try self.init(cgImage: cgImage)
    }

    func uiImage() throws(PPMError) -> UIKit.UIImage {
        let cgImage = try self.cgImage()
        return UIImage(cgImage: cgImage)
    }
}
#endif
