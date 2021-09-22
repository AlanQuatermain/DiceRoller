//
//  SuccessFailure.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/10/21.
//

extension Modifiers {
    /// A modifier that counts the number of successful rolls, based on a
    /// provided comparison point.
    public struct Success: Modifier {
        /// The name of this modifier.
        public var name: String { "success" }
        /// The flag attached to values selected by this modifier.
        public var flag: String { "*" }
        /// The relative ordering of this modifier.
        public var order: Int { 7 }

        /// The comparison to use when determining if a roll is
        /// successful or not.
        public var comparison: ComparisonPoint

        /// Creates a new `Success` modifier.
        ///
        /// - Parameter comparison: The comparison to use when
        ///   inspecting roll results.
        public init(comparison: ComparisonPoint) {
            self.comparison = comparison
        }

        /// A string describing the modifier in terms that can be parsed
        /// by the dice roller, e.g. `">=5"`.
        public var description: String {
            comparison.description
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
            results.map {
                var newResult = $0
                if comparison.compare(newResult.value) {
                    newResult.criteria = .success
                    newResult.modifiers.append(self)
                }
                else {
                    newResult.criteria = .blank
                }
                return newResult
            }
        }
    }

    /// A modifier that counts the number of explicit failures in a group of
    /// rolls, reporting the results as a negative quantity.
    ///
    /// This modifier can only be used when it directly follows a `Success`
    /// modifier.
    public struct Failure: Modifier {
        /// The name of this modifier.
        public var name: String { "failure" }
        /// The flag attached by this modifier to affected values.
        public var flag: String { "_" }
        /// The relative ordering of this modifier.
        public var order: Int { 7 }

        /// The comparison used to detect if a roll is considered a failure.
        public var comparison: ComparisonPoint

        /// Creates a new `Failure` modifier.
        ///
        /// - Parameter comparison: The comparison to use when
        ///   inspecting roll results.
        public init(comparison: ComparisonPoint) {
            self.comparison = comparison
        }

        /// A string describing the modifier in terms that can be parsed
        /// by the dice roller, e.g. `"f<3"`.
        public var description: String {
            "f\(comparison)"
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
            results.map {
                var newResult = $0
                // Don't assign 'blank', that's already been done by the success modifier
                if comparison.compare(newResult.value) {
                    newResult.criteria = .failure
                    newResult.modifiers.append(self)
                }
                return newResult
            }
        }
    }

    /// A modifier that calls out critical successes in roll results.
    ///
    /// - Note: This modifier does not affect the outcome of the roll, it merely
    ///   attaches a flag to matching values to call them out visually.
    public struct CriticalSuccess: Modifier {
        /// The name of this modifier.
        public var name: String { "critical-success" }
        /// The flag attached by this modifier to matching values.
        public var flag: String { "**" }
        /// The relative ordering of this modifier.
        public var order: Int { 8 }

        /// The comparison point used to determine a match.
        public var comparison: ComparisonPoint

        /// Creates a new `CriticalSuccess` modifier.
        ///
        /// - Parameter comparison: The comparison used to
        ///   determine a match.
        public init(comparison: ComparisonPoint) {
            self.comparison = comparison
        }

        /// A string describing the modifier in terms that can be parsed
        /// by the dice roller, e.g. `"cs=20"`.
        public var description: String {
            "cs\(comparison)"
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
            results.map {
                var newResult = $0
                if comparison.compare(newResult.value) {
                    newResult.modifiers.append(self)
                }
                return newResult
            }
        }
    }

    /// A modifier that calls out critical failures in roll results.
    ///
    /// - Note: This modifier does not affect the outcome of the roll, it merely
    ///   attaches a flag to matching values to call them out visually.
    public struct CriticalFailure: Modifier {
        /// The name of the modifier.
        public var name: String { "critical-failure" }
        /// The flag attached by this modifier to matching values.
        public var flag: String { "__" }
        /// The relative ordering of this modifier.
        public var order: Int { 9 }

        /// The comparison point used to deretmine a match.
        public var comparison: ComparisonPoint

        /// Creates a new `CriticalFailure` modifier.
        ///
        /// - Parameter comparison: The comparison used to
        ///   determine a match.
        public init(comparison: ComparisonPoint) {
            self.comparison = comparison
        }

        /// A string describing the modifier in terms that can be parsed
        /// by the dice roller, e.g. `"cf=1"`.
        public var description: String {
            "cf\(comparison)"
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
            results.map {
                var newResult = $0
                if comparison.compare(newResult.value) {
                    newResult.modifiers.append(self)
                }
                return newResult
            }
        }
    }
}
