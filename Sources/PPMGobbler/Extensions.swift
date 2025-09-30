//
//  Extensions.swift
//  PPMGobbler
//
//  Created by syan on 25/08/2025.
//

import Foundation
import simd

internal extension RandomAccessCollection where Index == Int {
    func split(subsequenceSize: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: subsequenceSize).map {
            Array(self[$0..<Swift.min(count, $0 + subsequenceSize)])
        }
    }
}

internal extension Array {
    func fillup(to size: Int, using element: Element) -> [Element] {
        var result = self
        result.reserveCapacity(size)
        while result.count < size {
            result.append(element)
        }
        return result
    }
}

internal extension Double {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

internal extension UInt8 {
    static let asciiSpace = UInt8(ascii: " ")
    static let asciiTab = UInt8(ascii: "\t")
    static let asciiLineFeed = UInt8(ascii: "\n")
    static let asciiLineReturn = UInt8(ascii: "\r")
    static let asciiWhitespaces: Set<UInt8> = [
        .asciiSpace,
        .asciiTab,
        .asciiLineFeed,
        .asciiLineReturn
    ]
}

