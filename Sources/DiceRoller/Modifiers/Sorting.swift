//
//  Sorting.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/10/21.
//

extension Modifiers {
    /// A modifier that sorts the output of a set of rolled dice.
    public struct Sorting: Modifier {
        /// The name of this modifier.
        public var name: String { "sorting" }
        /// The flags attached by this modifier to affected values (none for `Sorting`).
        public var flag: String { "" }
        /// The relative ordering of this modifier.
        ///
        /// `Sorting` always comes last.
        public var order: Int { Int.max } // always last

        /// Whether the values should be sorted in ascending or
        /// descending order.
        let ascending: Bool

        /// Creates a new `Sorting` modifier.
        ///
        /// - Parameter ascending: Sort in ascending order (the default).
        public init(ascending: Bool = true) {
            self.ascending = ascending
        }

        /// Applies the effects of the modifier to the results of a roll.
        ///
        /// - Parameter results: A sequence of `RollResult` instances,
        ///   each representing the result of rolling a single die.
        /// - Parameter roll: A method that can be used to roll additional
        ///   dice, should the modifier require it (e.g. exploding or rerolling).
        /// - Returns: An array of `RollResults` representing the new state of the
        ///   die roll.
        public func run<R>(for results: R, using roll: () -> Int) -> [RollResult] where R : Sequence, R.Element == RollResult {
            ascending ? results.sorted(by: <) : results.sorted(by: >)
        }

        /// A string describing the modifier in terms that can be parsed
        /// by the dice roller, e.g. `"sa"`.
        public var description: String {
            "s\(ascending ? "a" : "d")"
        }
    }
}
