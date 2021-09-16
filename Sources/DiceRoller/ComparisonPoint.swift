//
//  ComparisonPoint.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/9/21.
//

public enum Comparison: String {
    /// Rolls matching a given value.
    case equal = "="
    /// Rolls not matching a given value.
    case notEqual = "<>"
    /// Rolls exceeding a given value.
    case greater = ">"
    /// Rolls equalling or exceeding a given value.
    case greaterEqual = ">="
    /// Rolls below a given value.
    case lesser = "<"
    /// Rolls equaling or below a given value.
    case lesserEqual = "<="

    /// Special case for 'maximum value of die.'
    case maxRoll = ""

    var `operator`: String { rawValue }

    public init?(rawValue: String) {
        switch rawValue {
        case "=": self = .equal
        case "<>", "!=": self = .notEqual
        case ">": self = .greater
        case ">=": self = .greaterEqual
        case "<": self = .lesser
        case "<=": self = .lesserEqual
        case "": self = .maxRoll
        default:
            return nil
        }
    }
}

public struct ComparisonPoint {
    public var comparison: Comparison
    public var value: Int

    public init(comparison: Comparison, value: Int) {
        self.comparison = comparison
        self.value = value
    }

    public init(maximumOf die: Dice) {
        self.comparison = .maxRoll
        self.value = die.dieRange.upperBound
    }

    public var `operator`: String {
        if case .maxRoll = comparison {
            return ""
        }
        else {
            return description
        }
    }
}

public extension ComparisonPoint {
    func compare(_ input: Int) -> Bool {
        switch comparison {
        case .equal, .maxRoll:
            return input == value
        case .notEqual:
            return input != value
        case .greater:
            return input > value
        case .greaterEqual:
            return input >= value
        case .lesser:
            return input < value
        case .lesserEqual:
            return input <= value
        }
    }
}

extension ComparisonPoint: CustomStringConvertible {
    public var description: String {
        if case .maxRoll = comparison {
            return "==\(value)"
        }
        else {
            return "\(comparison.rawValue)\(value)"
        }
    }
}

extension Comparison: Equatable {}
extension ComparisonPoint: Equatable {}
