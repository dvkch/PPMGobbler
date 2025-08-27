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
                while let c = readByte(), c != UInt8.asciiLineFeed, c != UInt8.asciiLineReturn {}
            }
            else if UInt8.asciiWhitespaces.contains(b) {
                _ = readByte()
            }
            else {
                break
            }
        }
    }
    
    mutating func readInt(maxChars: Int = Int.max) -> UInt {
        skipWhitespaceAndComments()
        var readChars = 0
        var val: UInt = 0
        while let b = peekByte(), b >= UInt8(ascii: "0") && b <= UInt8(ascii: "9") {
            _ = readByte()
            val = val * 10 + UInt(b - UInt8(ascii: "0"))
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
