//
//  DataReader.swift
//  PPMGobbler
//
//  Created by syan on 27/08/2025.
//

import Foundation

internal struct DataReader {
    init(data: Data) {
        self.data = data
    }
    
    let data: Data
    private(set) var index: Int = 0
    
    mutating func start() {
        index = 0
    }

    mutating func skip(amount: Int) {
        index += amount
    }

    mutating func readByte() -> UInt8? {
        guard index < data.count else { return nil }
        let b = data[index]
        index += 1
        return b
    }
    
    mutating func peekByte() -> UInt8? {
        index < data.count ? data[index] : nil
    }
    
    mutating func skipWhitespaceAndComments() {
        while let b = peekByte() {
            if b == UInt8(ascii: "#") {
                while let c = readByte(), c != 10, c != 13 {}
            } else if b == 9 || b == 10 || b == 13 || b == 32 {
                _ = readByte()
            } else {
                break
            }
        }
    }
    
    mutating func readInt(maxChars: Int = Int.max) -> UInt {
        skipWhitespaceAndComments()
        var readChars = 0
        var val: UInt = 0
        while let b = peekByte(), b >= 48 && b <= 57 {
            _ = readByte()
            val = val * 10 + UInt(b - 48)
            readChars += 1
            if readChars >= maxChars { break }
        }
        return val
    }
    
    mutating func readSample(size: Int) throws(PPMError) -> UInt16 {
        if size == 1 {
            guard let b = readByte() else {
                throw PPMError.mismatchWidthHeightAndContent
            }
            return UInt16(b)
        }
        else {
            guard let high = readByte(), let low = readByte() else {
                throw PPMError.mismatchWidthHeightAndContent
            }
            return (UInt16(high) << 8) | UInt16(low)
        }
    }
}
