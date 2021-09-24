//
//  MinMax.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/10/21.
//

extension Modifiers {
    /// A modifier that rounds rolled values up to a specified minimum.
    public struct Minimum: Modifier {
        /// The name of this modifier.
        public var name: String { "minimum" }
        /// The flag attached to results affected by this modifier.
        public var flag: String { "^" }
        /// The minimum value to use.
        public let value: Int
        /// The relative ordering of this modifier.
        public var order: Int { 1 }

        /// Creates a new `Minimum` modifier.
        ///
        /// - Parameter value: The minimum value. Rolls below this value
        ///   will be rounded up by this modifier.
        public init(value: Int) {
            self.value = value
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
                guard $0.value < value else { return $0 }
                return RollResult(value: value, modifiers: $0.modifiers + [self])
            }
        }

        /// A string describing the operator in terms that can be parsed by
        /// the dice roller, e.g. `"min3"`
        public var description: String {
            "min\(value)"
        }
    }

    /// A modifier that rounds rolled values down to a specified maximum.
    public struct Maximum: Modifier {
        /// The name of this modifier.
        public var name: String { "maximum" }
        /// The flag attached to values affected by this modifier.
        public var flag: String { "v" }
        /// The maximum value to use.
        public let value: Int
        /// The relative ordering of this modifier.
        public var order: Int { 2 }

        /// Creates a new `Maximum` modifier.
        ///
        /// - Parameter value: The maximum value. Rolls above this value
        ///   will be rounded down by this modifier.
        public init(value: Int) {
            self.value = value
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
                guard $0.value > value else { return $0 }
                return RollResult(value: value, modifiers: $0.modifiers + [self])
            }
        }

        /// A string describing this modifier in terms that can be parsed by
        /// the dice roller, e.g. `"max5"`.
        public var description: String {
            "max\(value)"
        }
    }
}
