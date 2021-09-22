//
//  File.swift
//  File
//
//  Created by Jim Dovey on 9/8/21.
//

import RealModule
import Darwin

/// A method that acts like a die roll, producing a single value.
public typealias Roller = () -> Int

/// Represents the different dice understood by this library.
public enum Dice {
    /// A standard die with numbered sides in the range `1...sides`.
    ///
    /// - Parameter sides: The number of sides on the die.
    /// - Parameter count: The number of dice being rolled.
    case standard(sides: Int, count: Int)
    /// A percentage die, or d100.
    ///
    /// - Parameter count: The number of dice being rolled.
    case percent(count: Int)
    /// A fate or fudge die, where some sides are blank, and the
    /// others contain equal numbers of 'success' and 'failure' values.
    ///
    /// This type assumes a six-sided die with two configurations: either
    /// it has two each success, failure, and blank faces, or it has
    /// four blank faces, one success, and one failure.
    ///
    /// - Parameter lowProbability: If `true`, the die has only one success
    /// and one failure face; otherwise, there are two of each kind.
    /// - Parameter count: The number of dice being rolled.
    case fate(lowProbability: Bool, count: Int)

    /// The possible value range from a single die of this type.
    public var dieRange: ClosedRange<Int> {
        switch self {
        case .standard(let sides, _):
            return 1...sides
        case .percent:
            return 1...100
        case .fate:
            return -1...1
        }
    }

    /// The number of dice being rolled.
    public var dieCount: Int {
        switch self {
        case let .standard(_, count), let .percent(count), let .fate(_, count):
            return count
        }
    }

    /// The possible result range ot the entire roll, using all dice.
    public var rollRange: ClosedRange<Int> {
        switch self {
        case let .standard(sides, count):
            return count...(sides*count)
        case let .percent(count):
            return count...(count*100)
        case let .fate(_, count):
            return (0-count)...count
        }
    }

    /// Rolls a single die of the receiver's type.
    ///
    /// - Returns: The result of a single roll.
    public func rollOnce() -> Int {
        if case let .fate(lowProb, _) = self, lowProb == true {
            switch Int.random(in: 1...6) {
            case 1:  return -1
            case 6:  return 1
            default: return 0
            }
        }

        return Int.random(in: dieRange)
    }

    /// Rolls all the dice.
    ///
    /// - Returns: An array of `RollResult` instances, one per
    /// die rolled.
    public func rollAll() -> [RollResult] {
        (0..<dieCount)
            .map { _ in rollOnce() }
            .map { RollResult(value: $0) }
    }

    /// Returns a `Dictionary` giving the probabilities of each possible result
    /// on the dice.
    ///
    /// - Note: Be warned that while this is accurate enough for most common cases,
    /// once you start passing in more than ten dice the algorithm will run up against
    /// the limits of the `Float80` type used for computations internally.
    public func probabilities() -> [Int: Double] {
        // Binomial coefficient:
        //      $\binom{n}{k} = \frac{n!}{k!(n-k)!}$
        //
        // Probability of rolling $p$ on $n$ $s$-sided dice:
        //
        //  $P(p,n,s) = \frac{1}{s^n}\cdot\sum_{k=0}^{k_{max}}(-1)^k\binom{n}{k}\binom{p - s\cdot k - 1}{p - s\cdot k - n}$
        //
        //  where $k_{max} = \floor{\frac{p-n}{s}}$
        func factorial(_ n: Int) -> Float80 {
            func _fact(_ n: Float80) -> Float80 {
                if n <= 1 {
                    return 1
                }
                return n * _fact(n-1)
            }
            return _fact(Float80(n))
        }

        func binomial(n: Int, k: Int) -> Float80 {
            let nf = factorial(n)
            let kf = factorial(k)
            let nkf = factorial(n-k)

            return nf / (kf * nkf)
        }

        func probability(p: Int, n: Int, s: Int) -> Float80 {
            let _p = Float80(p)
            let _n = Float80(n)
            let _s = Float80(s)

            let stoN = Float80.pow(_s, _n)
            let oneOverStoN = Float80(1) / stoN

            let kMax = Int(floorl((_p - _n) / _s))
            let sum = (0...kMax).lazy
                .map { (k: Int) -> Float80 in
                    let sk = s*k
                    let kp = Float80.pow(-1.0, k)
                    let b1 = binomial(n: n, k: k)
                    let b2 = binomial(n: p-sk-1, k: p-sk-n)
                    return kp * b1 * b2
                }
                .reduce(0) { $0 + $1 }

            return oneOverStoN * sum
        }

        let Ps = self.rollRange.map { (p: Int) -> (Int, Double) in
            let P = probability(p: p, n: self.dieCount, s: self.dieRange.count)
            return (p, Double(P))
        }
        return Dictionary(uniqueKeysWithValues: Ps)
    }
}

/// Represents a roll of a set of dice, including any modifiers but absent arithmetic.
public struct Roll {
    /// The dice being rolled.
    public var dice: Dice
    /// Any modifiers to apply to the output of the roll.
    public var modifiers: [Modifier]

    /// Creates a new `Roll` of the given dice, with specifiec modifiers.
    ///
    /// - Parameters:
    ///   - dice: The dice to roll.
    ///   - modifiers: Modifiers to apply to the roll, if any.
    public init(dice: Dice, modifiers: [Modifier] = []) {
        self.dice = dice
        self.modifiers = modifiers
    }

    /// The range of values output from a single die of the type used in
    /// this roll.
    public var range: ClosedRange<Int> { dice.dieRange }
    /// The number of dice being rolled.
    public var count: Int { dice.dieCount }

    /// The range of outputs when rolling all dice for this roll, not including
    /// the potential effects of any modifiers.
    public var resultRange: ClosedRange<Int> { dice.rollRange }

    /// Rolls a single die of the roll's die type.
    public func rollOnce() -> Int {
        dice.rollOnce()
    }

    /// Rolls all dice and applies modifiers, producing a `RollResult` for
    /// each die rolled, including any extra rolled by modifiers.
    ///
    /// - Returns: The results of the roll, with modifiers applied.
    public func roll() -> [RollResult] {
        // modifiers are
        let modifiers = self.modifiers.ordered()
        let partitionIndex = modifiers.firstIndex { $0.order >= 5 } ?? modifiers.endIndex
        let dieModifiers = modifiers[..<partitionIndex]
        let rollModifiers = modifiers[partitionIndex...]

        var rolls = dice.rollAll()
            .flatMap { singleRoll -> [RollResult] in
                var rolls = [singleRoll]
                for modifier in dieModifiers {
                    rolls = modifier.run(for: rolls, using: self.rollOnce)
                }
                return rolls
            }

        for modifier in rollModifiers {
            rolls = modifier.run(for: rolls, using: self.rollOnce)
        }

        return rolls
    }
}

extension Dice: CustomStringConvertible {
    /// A description of the dice in standard format, e.g. `"2d6"`,
    /// `"d%"`, or `3dF.1`.
    public var description: String {
        switch self {
        case let .standard(sides, count):
            return "\(count)d\(sides)"
        case let .percent(count):
            return "\(count)d%"
        case let .fate(lowProb, count):
            if lowProb {
                return "\(count)dF.1"
            }
            else {
                return "\(count)dF"
            }
        }
    }
}

extension Roll: CustomStringConvertible {
    /// A representation of the dice being rolled, in standard format.
    ///
    /// This will produce a string suitable as input for the roll parser, e.g.
    /// `"3d6ro"`.
    public var description: String {
        "\(dice)\(modifiers.map(\.description).joined())"
    }
}

extension Dice: Equatable, Comparable {
    public static func < (lhs: Dice, rhs: Dice) -> Bool {
        let lRange = lhs.rollRange
        let rRange = rhs.rollRange
        if lRange.lowerBound < rRange.lowerBound {
            return true
        }
        if lRange.lowerBound > rRange.lowerBound {
            return false
        }
        if lRange.upperBound < rRange.upperBound {
            return true
        }
        return false
    }
}

extension Roll: Equatable, Comparable {
    public static func == (lhs: Roll, rhs: Roll) -> Bool {
        if lhs.dice != rhs.dice { return false }
        if lhs.modifiers.isEmpty && rhs.modifiers.isEmpty { return true }
        if lhs.modifiers.count != rhs.modifiers.count { return false }

        // cheap & cheerful
        let lMods = lhs.modifiers.ordered().map(\.description).joined()
        let rMods = rhs.modifiers.ordered().map(\.description).joined()
        return lMods == rMods
    }

    public static func < (lhs: Roll, rhs: Roll) -> Bool {
        if lhs.dice != rhs.dice { return lhs.dice < rhs.dice }
        if lhs.modifiers.count != rhs.modifiers.count {
            return lhs.modifiers.count < rhs.modifiers.count
        }

        let lMods = lhs.modifiers.ordered().map(\.description).joined()
        let rMods = rhs.modifiers.ordered().map(\.description).joined()
        return lMods < rMods
    }
}
