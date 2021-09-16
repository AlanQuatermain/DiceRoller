//
//  File.swift
//  File
//
//  Created by Jim Dovey on 9/8/21.
//

public protocol Rollable {
    var range: ClosedRange<Int> { get }
    var count: Int { get }
    var modifiers: [Modifier] { get }

    func roll() -> [RollResult]
    func rollOnce() -> Int
}

public typealias Roller = () -> Int

public enum Dice {
    case standard(sides: Int, count: Int)
    case percent(count: Int)
    case fate(lowProbability: Bool, count: Int)

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

    public var dieCount: Int {
        switch self {
        case let .standard(_, count), let .percent(count), let .fate(_, count):
            return count
        }
    }

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

    public func rollAll() -> [RollResult] {
        (0..<dieCount)
            .map { _ in rollOnce() }
            .map { RollResult(value: $0) }
    }
}

public struct Roll: Rollable {
    public var dice: Dice
    public var modifiers: [Modifier]

    public init(dice: Dice, modifiers: [Modifier] = []) {
        self.dice = dice
        self.modifiers = modifiers
    }

    public var range: ClosedRange<Int> { dice.dieRange }
    public var count: Int { dice.dieCount }

    public var resultRange: ClosedRange<Int> { dice.rollRange }

    public func rollOnce() -> Int {
        dice.rollOnce()
    }

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
