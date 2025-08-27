//
//  PPMError.swift
//  PPMGobbler
//
//  Created by syan on 25/08/2025.
//

import Foundation

public enum PPMError: Error, Sendable, Hashable {
    case invalidHeader(_ message: String)
    case mismatchWidthHeightAndContent
    case unsupportedPixelType
    case cannotGenerateCGImage
    case missingCGImage
}
