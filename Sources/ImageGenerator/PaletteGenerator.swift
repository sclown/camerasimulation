import UIKit

public extension [UIColor] {
    static func palette(text: String, aplha: CGFloat = 1.0) -> [UIColor] {
        guard !text.isEmpty else {
            return [.white, .white, .white, .white]
        }
        var generator = SeededRandomGenerator(text)
        return [
            Self.generateColor(alpha: aplha, generator: &generator),
            Self.generateColor(alpha: aplha, generator: &generator),
            Self.generateColor(alpha: aplha, generator: &generator),
            Self.generateColor(alpha: aplha, generator: &generator)
        ]
    }
    
    private static func generateColor(
        alpha: CGFloat = 1.0,
        generator: inout SeededRandomGenerator
    ) -> UIColor {
        let red = CGFloat.random(in: 0...1, using: &generator)
        let green = CGFloat.random(in: 0...1, using: &generator)
        let blue = CGFloat.random(in: 0...1, using: &generator)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// A random number generator that produces consistent results for the same seed
private struct SeededRandomGenerator: RandomNumberGenerator {
    private var seed: UInt64
    
    init(_ text: String) {
        var seed: UInt64 = 0
        for char in text {
            seed = seed &+ UInt64(char.asciiValue ?? 0)
            seed = seed &* 747796405
        }
        self.seed = seed
    }
    
    mutating func next() -> UInt64 {
        // XorShift algorithm https://en.wikipedia.org/wiki/Xorshift
        seed ^= seed << 13
        seed ^= seed >> 7
        seed ^= seed << 17
        return seed
    }
}
