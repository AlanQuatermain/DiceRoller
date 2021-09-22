//
//  Operations.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/9/21.
//

/// A die roll modifier.
///
/// Modifiers are used to make changes to the output values of a roll.  These
/// are die-specific operations, such as exploding, or success/failure targets.
///
/// See the `Modifiers` type for the concrete modifiers supported.
public protocol Modifier: CustomStringConvertible {
    /// The name of the modifier. Human-readable.
    var name: String { get }
    /// The flags associated with the modifier.
    ///
    /// These are the characters appended to roll descriptions in
    /// `RollResult` output to denote application of a given
    /// modifier, for instance `"d"` to denote dropped dice in
    /// output like `"[5, 1d, 3d]`.
    var flag: String { get }
    /// The relative ordering of this modifier against others. Default = 999.
    ///
    /// Lower order modifiers are computed first.
    var order: Int { get }

    /// Applies the effects of the modifier to the results of a roll.
    ///
    /// - Parameter results: A sequence of `RollResult` instances,
    ///   each representing the result of rolling a single die.
    /// - Parameter roll: A method that can be used to roll additional
    ///   dice, should the modifier require it (e.g. exploding or rerolling).
    /// - Returns: An array of `RollResults` representing the new state of the
    ///   die roll.
    func run<R: Sequence>(for results: R, using roll: Roller) -> [RollResult] where R.Element == RollResult
}

extension Modifier {
    public var order: Int { 999 }
}

/// Namespace for concrete modifiers provided by this library.
public enum Modifiers {
    /// The maximum number of times a modifier can be applied to
    /// a single roll.
    public static var iterationLimit = 1000
}

extension Sequence where Element == Modifier {
    /// Returns the sequence of modifiers ordered according to their
    /// `order` property.
    func ordered() -> [Element] {
        sorted { $0.order < $1.order }
    }
}
