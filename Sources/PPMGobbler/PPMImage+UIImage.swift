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
    var uiImage: UIKit.UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
#endif
