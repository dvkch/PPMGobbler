//
//  PPMFormat.swift
//  PPMGobbler
//
//  Created by syan on 25/08/2025.
//

import Foundation

public enum PPMFormat: String, CaseIterable, Sendable {
    case P1 = "P1"
    case P2 = "P2"
    case P3 = "P3"
    case P4 = "P4"
    case P5 = "P5"
    case P6 = "P6"
    
    public var isBinary: Bool {
        switch self {
        case .P1, .P2, .P3: return false
        case .P4, .P5, .P6: return true
        }
    }
    
    public var bitsPerComponent: UInt {
        switch self {
        case .P1, .P4: return 1
        case .P2, .P5: return 8
        case .P3, .P6: return 8
        }
    }
    
    public var numberOfComponents: UInt {
        switch self {
        case .P1, .P4: return 1
        case .P2, .P5: return 1
        case .P3, .P6: return 3
        }
    }
    
    public var fileExtension: String {
        switch self {
        case .P1, .P4: return "pbm"
        case .P2, .P5: return "pgm"
        case .P3, .P6: return "ppm"
        }
    }
    
    public var defaultLevels: UInt16 {
        switch self {
        case .P1, .P4: return 1
        case .P2, .P5: return 255
        case .P3, .P6: return 255
        }
    }
}
