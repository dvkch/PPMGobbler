//
//  PPMFile.swift
//  PPMGobbler
//
//  Created by syan on 26/08/2025.
//

import Foundation

public struct PPMFile: Sendable, Equatable {
    public let format: PPMFormat
    public let width: UInt
    public let height: UInt
    public let levels: UInt16
    public let pixels: [UInt16]
    
    public init(format: PPMFormat, width: UInt, height: UInt, levels requiredLevels: UInt16? = nil, pixels: [UInt16]) {
        self.format = format
        self.width = width
        self.height = height
        self.levels = format.bitsPerComponent == 1 ? 1 : (requiredLevels ?? format.defaultLevels)
        self.pixels = pixels
        
        let nbPixels = width * height * format.numberOfComponents
        guard pixels.count == width * height * format.numberOfComponents else {
            fatalError("Invalid pixels count, expect \(nbPixels) (\(width)x\(height)x\(format.numberOfComponents)), got \(pixels.count)")
        }
    }

    public init(data: Data) throws(PPMError) {
        var reader = DataReader(data: data)
        reader.start()
        
        // Detect format
        guard reader.readByte() == 80 else { throw PPMError.invalidHeader("Missing 'P' magic") }
        let formatString = reader.readByte()
        switch formatString {
        case 49: format = .P1
        case 50: format = .P2
        case 51: format = .P3
        case 52: format = .P4
        case 53: format = .P5
        case 54: format = .P6
        default: throw PPMError.invalidHeader("Unknown Netpbm format P\(String(describing: formatString))")
        }
               
        // Detect dimensions
        width = reader.readInt()
        height = reader.readInt()

        // Detect levels
        switch format {
        case .P1, .P4: levels = 1
        default: levels = UInt16(reader.readInt())
        }
        
        if format.isBinary {
            // Skip line break after dimensions and levels
            _ = reader.readByte()
        }

        // Read pixel data
        var pixels = [UInt16]()
        pixels.reserveCapacity(Int(width * height * format.numberOfComponents))
        switch format {
        case .P1:
            for _ in 0..<(width * height) {
                pixels.append(UInt16(reader.readInt(maxChars: 1) > 0 ? 1 : 0))
            }

        case .P2:
            for _ in 0..<(width * height) {
                pixels.append(UInt16(reader.readInt()))
            }
            
        case .P3:
            for _ in 0..<(width * height * 3) {
                pixels.append(UInt16(reader.readInt()))
            }

        case .P4:
            let rowLengthInBytes = Int((width + 7) / 8)
            for _ in 0..<height {
                for x in 0..<width {
                    let byteIndex = reader.index + (Int(x) / 8)
                    let bit = 7 - (Int(x) % 8)
                    let val = (reader.data[byteIndex] >> bit) & 1
                    pixels.append(val > 0 ? 1 : 0)
                }
                reader.skip(amount: rowLengthInBytes)
            }

        case .P5:
            let sampleSize = (levels < 256) ? 1 : 2
            for _ in 0..<(width * height) {
                pixels.append(try reader.readSample(size: sampleSize))
            }

        case .P6:
            let sampleSize = (levels < 256) ? 1 : 2
            for _ in 0..<(width * height * 3) {
                pixels.append(try reader.readSample(size: sampleSize))
            }
        }
        
        self.pixels = pixels
    }
    
    public var data: Data {
        var header = "\(format.rawValue)\n\(width) \(height)\n"
        if format.bitsPerComponent > 1 {
            header += "\(UInt16(levels))\n"
        }

        switch format {
        case .P1, .P2, .P3:
            let pixels = pixels
                .split(subsequenceSize: Int(width * format.numberOfComponents))
                .map { row in
                    row
                        .map { String(Swift.min($0, levels)) }
                        .joined(separator: " ") + " "
                }
                .joined(separator: "\n") + "\n"
            return (header + pixels).data(using: .ascii)!

        case .P4:
            let pixels = pixels
                .split(subsequenceSize: Int(width))
                .map { row -> [UInt8] in
                    row
                        .split(subsequenceSize: 8)
                        .map { rowBits in rowBits.fillup(to: 8, using: 0) }
                        .map { rowBits -> UInt8 in
                            let b7: UInt8 = (rowBits[0] > 0 ? 1 : 0) << 7
                            let b6: UInt8 = (rowBits[1] > 0 ? 1 : 0) << 6
                            let b5: UInt8 = (rowBits[2] > 0 ? 1 : 0) << 5
                            let b4: UInt8 = (rowBits[3] > 0 ? 1 : 0) << 4
                            let b3: UInt8 = (rowBits[4] > 0 ? 1 : 0) << 3
                            let b2: UInt8 = (rowBits[5] > 0 ? 1 : 0) << 2
                            let b1: UInt8 = (rowBits[6] > 0 ? 1 : 0) << 1
                            let b0: UInt8 = (rowBits[7] > 0 ? 1 : 0) << 0
                            return b7 | b6 | b5 | b4 | b3 | b2 | b1 | b0
                        }
                }.reduce([], +)
            return (header.data(using: .ascii)! + Data(pixels))

        case .P5, .P6:
            let pixels = pixels.map { pixel -> [UInt8] in
                let value = Swift.min(pixel, levels)
                if levels > 255 {
                    return [UInt8(value >> 8), UInt8(value & 0xFF)]
                }
                return [UInt8(value & 0xFF)]
            }.reduce([], +)
            return (header.data(using: .ascii)! + Data(pixels))
        }
    }
}
