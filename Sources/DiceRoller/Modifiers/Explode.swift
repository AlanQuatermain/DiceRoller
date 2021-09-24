//
//  Explode.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/9/21.
//

extension Modifiers {
    /// The explosion modifier.
    ///
    /// An exploding die (specified using the `"!"` character) is compared
    /// against a comparison point (default of 'maximum die value'). If the
    /// comparison succeeds, then the die 'explodes' and another of its kind
    /// is rolled.
    ///
    /// There are three types of exploding dice:
    ///
    /// - Exploding (`"!"`) will roll additional dice so long as the condition
    /// is met, comparing against all new rolls. This can lead to results such as
    /// `3d6! = [2, 4, 6!, 1]`.
    /// - Compounding (`"!!"`) will explode as above, but will accumulate
    /// the results of all exploded dice into a single value. This can lead to results
    /// such as `3d6!! = [5, 13!!, 7!!]`.
    /// - Penetrating (`"!p"`) will roll and explode as Exploding dice, but
    /// the resulting value of each newly-rolled die will be reduced by one. This
    /// can lead to results such as `3d6!p = [4, 6!p, 0, 3]`.
    public struct Explode: Modifier {
        /// The name of this modifier.
        public var name: String { "explode" }
        /// The flag appended to outputs where this modifier has been
        /// applied.
        public var flag: String {
            switch format {
            case .exploding: return "!"
            case .compounding: return "!!"
            case .penetrating: return "!p"
            }
        }
        /// The relative ordering of this modifier.
        public var order: Int { 3 }

        /// A string describing the operator in terms that can be parsed by
        /// the dice roller, e.g. `"!p>=5"`
        public var description: String {
            flag + comparison.operator
        }

        /// Defines the different types of exploding die.
        public enum Format {
            /// Add another roll result each time a roll matches the comparison.
            case exploding
            /// Roll again each time a roll matches the comparison, accumulating
            /// in a single result.
            case compounding
            /// Add another roll as for `.exploding`, but subtract 1 from the
            /// result of that roll when recording it.
            case penetrating
        }

        /// The type of explosion to use.
        public private(set) var format: Format = .exploding
        /// The comparison point used to match against rolled values.
        public private(set) var comparison: ComparisonPoint

        /// Creates a new exploding die modifier.
        ///
        /// - Parameters:
        ///   - comparison: The comparison used to match rolls.
        ///   - format: The type of explosion to use.
        public init(
            comparison: ComparisonPoint,
            format: Format = .exploding
        ) {
            self.comparison = comparison
            self.format = format
        }

        /// Creates a new exploding die modifier that matches against
        /// the highest possible roll of a particular die type.
        ///
        /// - Parameters:
        ///   - die: The type and size of die whose maximum to use
        ///   when comparing results.
        ///   - format: The type of explosion to use.
        public init(
            for die: Dice,
            format: Format = .exploding
        ) {
            comparison = .init(maximumOf: die)
            self.format = format
        }

        /// Runs the modifier, applying its effects to the input roll results.
        ///
        /// - Parameters:
        ///   - results: A sequence of `RollResult` instances to apply the modifier to.
        ///   - roller: A function that will produce a new roll of the same type as the
        ///   original die roll.
        /// - Returns: An array of `RollResult` instances describing the modified
        ///   rolls.
        public func run<R>(
            for results: R,
            using roller: () -> Int
        ) -> [RollResult] where R : Sequence, R.Element == RollResult {
            switch format {
            case .exploding:
                return results.flatMap { self.explode(roll: $0, using: roller) }
            case .compounding:
                return results.flatMap { self.compound(roll: $0, using: roller) }
            case .penetrating:
                return results.flatMap { self.penetrate(roll: $0, using: roller) }
            }
        }

        /// Performs a non-compounding explosion, optionally subtracting a value from
        /// the results of any additional rolls made.
        ///
        /// - Parameters:
        ///   - roll: A single `RollResult` to evaluate.
        ///   - roller: A function that will produce a new roll.
        ///   - subtract: An optional value to subtract from new rolls.
        /// - Returns: An array of `RollResult` instances containing the results.
        private func explode(roll: RollResult, using roller: () -> Int, subtract: Int = 0) -> [RollResult] {
            guard comparison.compare(roll.value) else {
                return [roll]
            }

            var output: [RollResult] = []
            var rolled = roll.value
            var again = true
            var iterations = 0

            output.append(RollResult(value: rolled, modifiers: roll.modifiers + [self]))
            repeat {
                rolled = roller()
                again = comparison.compare(rolled)
                var newRoll = RollResult(value: rolled - subtract, modifiers: roll.modifiers)
                if again {
                    newRoll.modifiers.append(self)
                }
                output.append(newRoll)
                iterations += 1
            } while again && iterations < iterationLimit

            return output
        }

        /// Performs a compounding explosion.
        ///
        /// - Parameters:
        ///   - roll: A single `RollResult` to evaluate.
        ///   - roller: A function that will produce a new roll.
        /// - Returns: An array of `RollResult` instances containing the results.
        private func compound(roll: RollResult, using roller: () -> Int) -> [RollResult] {
            var rolled = roll.value
            var total = rolled
            var iterations = 0

            while comparison.compare(rolled) && iterations < iterationLimit {
                rolled = roller()
                total += rolled
                iterations += 1
            }

            var modifiers = roll.modifiers
            if iterations > 0 {
                modifiers.append(self)
            }
            return [RollResult(value: total, modifiers: modifiers)]
        }

        /// Performs a penetrating explosion.
        ///
        /// - Parameters:
        ///   - roll: A single `RollResult` to evaluate.
        ///   - roller: A function that will produce a new roll.
        /// - Returns: An array of `RollResult` instances containing the results.
        private func penetrate(roll: RollResult, using roller: () -> Int) -> [RollResult] {
            explode(roll: roll, using: roller, subtract: 1)
        }
    }
}
