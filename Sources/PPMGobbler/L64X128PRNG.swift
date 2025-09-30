//
//  L64X128PRNG.swift
//  PPMGobbler
//
//  Created by syan on 30/09/2025.
//

import Foundation

// https://dl.acm.org/doi/abs/10.1145/3485525
// from chat gpt and https://github.com/xavierleroy/pringo/commit/2e60db30cc16a7d6ed6be3cebeaae006bff31c56
internal struct L64X128PRNG: RandomNumberGenerator {
    let M: UInt64 = 0xd1342543de82ef95
    public struct LXMState {
        var a: UInt64
        var s: UInt64
        var x: (UInt64, UInt64)
        
        public init(a: UInt64, s: UInt64, x: (UInt64, UInt64)) {
            self.a = a
            self.s = s
            self.x = x
        }

        public init() {
            var generator = SystemRandomNumberGenerator()

            // Ensure a is odd
            a = 0
            while a % 2 == 0 {
                a = generator.next()
            }
            s = generator.next()

            // Ensure x[0] and x[1] are non-zero
            x = (0, 0)
            while x.0 == 0 {
                x.0 = generator.next()
            }
            while x.1 == 0 {
                x.1 = generator.next()
            }
        }
    }
    private var state: LXMState
    
    public init(seed: LXMState = .init()) {
        state = seed
    }
    
    func rotl(_ x: UInt64, _ k: Int) -> UInt64 {
        return (x &<< k) | (x &>> (64 - k))
    }
    
    public mutating func next() -> UInt64 {
        /* Combining operation */
        var z = state.s &+ state.x.0
 
        /* Mixing function */
        z = (z ^ (z >> 32)) &* 0xdaba0b6eb09322e3
        z = (z ^ (z >> 32)) &* 0xdaba0b6eb09322e3
        z = (z ^ (z >> 32))
        
        /* LCG update */
        state.s = state.s &* M &+ state.a
        
        /* XBG update */
        var q0 = state.x.0
        var q1 = state.x.1
        q1 ^= q0
        q0 = rotl(q0, 24)
        q0 = q0 ^ q1 ^ (q1 << 16)
        q1 = rotl(q1, 37)
        state.x.0 = q0
        state.x.1 = q1
        
        return z
    }
}
