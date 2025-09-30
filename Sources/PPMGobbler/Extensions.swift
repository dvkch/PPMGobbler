//
//  Extensions.swift
//  PPMGobbler
//
//  Created by syan on 25/08/2025.
//

import Foundation
import simd

internal extension Array {
    func split(subsequenceSize: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: subsequenceSize).map {
            Array(self[$0..<Swift.min(count, $0 + subsequenceSize)])
        }
    }
    
    func fillup(to size: Int, using element: Element) -> [Element] {
        var result = self
        result.reserveCapacity(size)
        while result.count < size {
            result.append(element)
        }
        return result
    }
}

internal extension RandomAccessCollection where Element == Double {
    var average: Element {
        return Double(reduce(0, +)) / Double(count)
    }
}

internal extension RandomAccessCollection where Element == Double, Index == Int {
    var fastAverage: Double {
        let n = count
        guard n > 0 else { return 0 }

        let simdCount = n & ~15 // largest multiple of 16
        var sumVec = SIMD16<Double>(repeating: 0)

        var i = 0
        while i < simdCount {
            let chunk = SIMD16<Double>(
                self[i + 0], self[i + 1], self[i + 2], self[i + 3],
                self[i + 4], self[i + 5], self[i + 6], self[i + 7],
                self[i + 8], self[i + 9], self[i + 10], self[i + 11],
                self[i + 12], self[i + 13], self[i + 14], self[i + 15]
            )
            sumVec += chunk
            i += 16
        }

        let remainder = self[simdCount..<n].reduce(0, +)
        let totalSum = sumVec.wrappedSum() + remainder
        return totalSum / Double(n)
    }
}

private extension SIMD16 where Scalar == Double {
    func wrappedSum() -> Double {
        return (
            self[0]     + self[1]   + self[2]   + self[3] +
            self[4]     + self[5]   + self[6]   + self[7] +
            self[8]     + self[9]   + self[10]  + self[11] +
            self[12]    + self[13]  + self[14]  + self[15]
        )
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

