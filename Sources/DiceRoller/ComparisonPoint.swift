//
//  ComparisonPoint.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/9/21.
//

/// Represents the arithmetic operations used in `ComparisonPoint` types.
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

    /// The textual representation of this comparison's operator.
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

/// A `ComparisonPoint` represents a single comparison operation
/// applied to a die roll.
///
/// Comparison points are used when attaching modifiers to die rolls,
/// providing modifier the means to determine whether a given roll
/// should be acted upon.
public struct ComparisonPoint {
    /// The comparison operator.
    public var comparison: Comparison
    /// The value to be tested with the operator.
    public var value: Int

    /// Creates a new `ComparisonPoint`.
    public init(comparison: Comparison, value: Int) {
        self.comparison = comparison
        self.value = value
    }

    /// Creates a new `ComparisonPoint` that matches the
    /// maximum possible value of a single die of the given type.
    ///
    /// - Parameter die: The die to match.
    public init(maximumOf die: Dice) {
        self.comparison = .maxRoll
        self.value = die.dieRange.upperBound
    }

    /// Returns a textual representation of the comparison point
    /// that can be parsed to recreate the receiver, such as
    /// `">3"` or `"<=2"`.
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
    /// Compares the input value against the represented comparison point.
    ///
    /// - Parameter input: The value to be compared.
    /// - Returns: The result of the comparison.
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
    /// A human-readable text representation of the comparison point.
    ///
    /// - Note: This is designed to be human-readable. For a representation
    /// that can be used in a die roll expression, use `operator`.
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
