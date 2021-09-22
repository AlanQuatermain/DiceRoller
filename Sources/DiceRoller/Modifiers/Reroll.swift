//
//  Reroll.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/10/21.
//

extension Modifiers {
    /// A modifier that re-rolls dice that meet a given criteria.
    ///
    /// There are two modes supported by the modifier: "re-roll" and "re-roll
    /// once." The former will evaluate any re-rolls made and potentially
    /// make further re-rolls. The latter will re-roll once at most, not inspecting
    /// the new value.
    ///
    /// The default comparison for this modifier is `"=1"`, i.e. "reroll any die
    /// that rolls the lowest value."
    public struct Reroll: Modifier {
        /// The name of the modifier.
        public var name: String { "reroll" }
        /// The flag attached to results affected by this modifier.
        public var flag: String { once ? "ro" : "r" }
        /// The relative ordering of this modifier.
        public var order: Int { 4 }

        /// If `true`, the modifier will only re-roll once, regardless the
        /// result of that re-roll. If `false`, it will continue re-rolling until
        /// it achieves a result that does not match its comparison.
        public let once: Bool
        /// The comparison to use when inspecting roll results.
        public let comparison: ComparisonPoint?

        /// Creates a new `Reroll` modifier.
        ///
        /// - Parameters:
        ///   - once: If `true`, re-rolls once, otherwise re-rolls
        ///     continuously.
        ///   - comparison: The comparison point to use. If not
        ///     specified, values `=1` are matched.
        public init(once: Bool = false, comparison: ComparisonPoint? = nil) {
            self.once = once
            self.comparison = comparison
        }

        /// A string describing the modifier in terms that can be parsed
        /// by the dice roller, e.g. `"r<3"`.
        public var description: String {
            if let comparison = comparison {
                return flag + "\(comparison)"
            }
            else {
                return flag
            }
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
            let comparison = self.comparison ?? ComparisonPoint(comparison: .equal, value: 1)
            return results.map {
                guard comparison.compare($0.value) else { return $0 }

                var newValue: Int
                repeat {
                    newValue = roll()
                } while comparison.compare(newValue) && once == false

                return RollResult(value: newValue, modifiers: $0.modifiers + [self])
            }
        }
    }
}
