//
//  PPMImage+Dithering.swift
//  PPMGobbler
//
//  Created by syan on 30/09/2025.
//

import Foundation
import Accelerate

public extension PPMImage where T == PPMPixelGrey {
    // noise: https://surma.dev/things/ditherpunk/
    func dither(limit suggestedLimit: Double? = nil, noise noiseFactor: Double = 0.5, factor: Double = 1.0 / 8.0) -> PPMImage<PPMPixelBW> {
        var buffer: ContiguousArray<Double> = .init(pixels.map(\.value))
        var output: ContiguousArray<PPMPixelBW> = []
        output.reserveCapacity(width * height)

        var random = L64X128PRNG()
        let limit = suggestedLimit ?? vDSP.mean(buffer)

        func addError(_ error: Double, x: Int, y: Int, dx: Int, dy: Int) {
            let nx = x + dx
            let ny = y + dy
            if nx >= 0, nx < width, ny >= 0, ny < height {
                buffer[ny * width + nx] = (buffer[ny * width + nx] + error * factor).clamped(to: 0...1)
            }
        }

        for y in 0..<height {
            for x in 0..<width {
                let noise: Double = Double.random(in: (-noiseFactor * limit)...(noiseFactor * limit), using: &random)
                let oldPixel = buffer[y * width + x] + noise
                let newPixel: Double = oldPixel >= limit ? 1.0 : 0.0
                output.append(.init(newPixel > 0.5))

                let error = oldPixel - newPixel

                // diffuse error to neighbors
                addError(error, x: x, y: y, dx:  1, dy: 0)
                addError(error, x: x, y: y, dx:  2, dy: 0)
                addError(error, x: x, y: y, dx: -1, dy: 1)
                addError(error, x: x, y: y, dx:  0, dy: 1)
                addError(error, x: x, y: y, dx:  1, dy: 1)
                addError(error, x: x, y: y, dx:  0, dy: 2)
            }
        }
        
        return try! .init(width: width, height: height, pixels: Array(output))
    }
}
