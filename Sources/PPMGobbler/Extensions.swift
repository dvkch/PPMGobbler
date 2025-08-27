//
//  Extensions.swift
//  PPMGobbler
//
//  Created by syan on 25/08/2025.
//

import Foundation

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
