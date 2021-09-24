//
//  RollResult.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/9/21.
//

/// Represents the result of a die roll, potentially including the effects of any
/// modifiers that have been applied.
///
/// This type is returned when calling `Dice.rollAll()`, with a single
/// `RollResult` for each individual die being rolled. The `Roll` type then
/// applies modifiers to the `RollResults`.
public struct RollResult: Calculable {
    /// The value of the (single) die rolled.
    public var value: Int
    /// A list of modifiers that affected this roll.
    ///
    /// This contains only the modifiers that actually matched and acted
    /// upon the value of this roll. For example, the `CriticalSuccess`
    /// modifier will be included here *only* if the roll's `value` met
    /// the criteria in the modifier.
    public var modifiers: [Modifier] = []
    /// Whether this die roll has been dropped, and should not be
    /// considered when calculating the value of a complete roll
    /// of multiple dice.
    public var dropped = false

    /// Defines the type of roll being made; a numeric value or a
    /// per-die success/failure condition.
    public enum TargetCriteria {
        /// This die represents a single success (logically +1).
        case success
        /// This die represents a single failure (logically -1).
        case failure
        /// This die is neither a success nor a failure (logically 0).
        case blank
        /// This die's value is used directly.
        case value
    }

    /// The type of roll represented by this `RollResult`.
    public internal(set) var criteria: TargetCriteria = .value

    /// The computed value of this die roll.
    ///
    /// This is affected by the `dropped` and `criteria` properties.
    /// If the die is dropped, or its criteria is `.blank`, then the computed
    /// value of the die is `0`. For a `.success` criteria, its value is `1`,
    /// while a `.failure` criteria makes its value `-1`.
    ///
    /// If the die is not dropped and has no special criteria, then its
    /// computed value is equal to its `value` property.
    public var computedValue: Int {
        guard dropped == false else { return 0 }

        switch criteria {
        case .success:
            return 1
        case .failure:
            return -1
        case .blank:
            return 0
        case .value:
            return value
        }
    }

    /// The flags representing the modifiers applied to this roll.
    ///
    /// These are used when printing out the description of the roll to
    /// indicated which modifiers applied. For example, a `"!"`
    /// indicates that the die exploded, or an `"r"` indicates it was
    /// re-rolled.
    public var modifierFlags: String {
        modifiers.map { $0.flag }.joined()
    }
}

extension RollResult: CustomStringConvertible {
    /// The die's value in standard output format, i.e. `"5!"` for a
    /// die that rolled a value of `5` and exploded.
    public var description: String {
        "\(value)\(modifierFlags)"
    }
}

extension RollResult: Hashable {
    public static func == (lhs: RollResult, rhs: RollResult) -> Bool {
        lhs.value == rhs.value && lhs.dropped == rhs.dropped
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        modifiers.forEach { hasher.combine($0.name) }
        hasher.combine(dropped)
    }
}

extension RollResult: Comparable {
    public static func < (lhs: RollResult, rhs: RollResult) -> Bool {
        lhs.value < rhs.value
    }
}
