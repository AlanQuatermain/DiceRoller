//
//  KeepDrop.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/10/21.
//

import Algorithms

extension Collection where Element: Comparable {
    func minIndices(
        count: Int,
        sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows -> [Index] {
        try indices
            .map { (index: $0, value: self[$0]) }
            .min(count: count) { try areInIncreasingOrder($0.value, $1.value) }
            .map { $0.index }
    }

    func maxIndices(
        count: Int,
        sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows -> [Index] {
        try indices
            .map { (index: $0, value: self[$0]) }
            .max(count: count) { try areInIncreasingOrder($0.value, $1.value) }
            .map { $0.index }
    }
}

extension Modifiers {
    /// A modifier that keeps only the highest values from a set of results.
    public struct Keep: Modifier {
        /// The name of the modifier.
        public var name: String { "keep" }
        /// The flag to attach to affected rolls.
        ///
        /// - Note: The keep modifier works by dropping any dice not matching
        ///   its comparison; the flag will be attached to the dropped dice.
        public var flag: String { "d" } // we attach to dropped rolls
        /// The relative ordering of this modifier.
        public var order: Int { 5 }

        /// Whether we are keeping high (the default) or low rolls.
        public var high: Bool
        /// The number of rolls to keep.
        public var count: Int

        /// Creates a new `Keep` modifier.
        ///
        /// - Parameters:
        ///   - high: If `true` (the default), keep the highest rolls. If `false`,
        ///   keep the lowest.
        ///   - count: The number of rolls to keep; defaults to `1`.
        public init(high: Bool = true, count: Int = 1) {
            self.high = high
            self.count = count
        }

        private var sortFunction: (RollResult, RollResult) -> Bool {
            if high {
                return { $0 < $1 }
            }
            else {
                return { $0 > $1 }
            }
        }

        /// Applies the effects of the modifier to the results of a roll.
        ///
        /// - Parameter results: A sequence of `RollResult` instances,
        /// each representing the result of rolling a single die.
        /// - Parameter roll: A method that can be used to roll additional
        /// dice (unused in this modifier).
        public func run<R>(for results: R, using roll: () -> Int) -> [RollResult] where R : Sequence, R.Element == RollResult {
            var output = Array(results)
            for index in output.minIndices(count: output.count - count, sortedBy: sortFunction) {
                output[index].dropped = true
                output[index].modifiers.append(self)
            }
            return output
        }

        /// A string describing the operator in terms that can be parsed by
        /// the dice roller, e.g. `"kh1"`
        public var description: String {
            "k\(high ? "h" : "l")\(count)"
        }
    }

    /// A modifier that drops the lowest values from a set of results.
    public struct Drop: Modifier {
        /// The name of the modifier.
        public var name: String { "drop" }
        /// The flag applied by the modifier to dropped results.
        public var flag: String { "d" }
        /// The relative ordering of this modifier.
        public var order: Int { 6 }

        /// Whether we are dropping high or low (the default) rolls.
        public var high: Bool
        /// The number of dice to drop.
        public var count: Int

        /// Creates a new `Drop` modifier.
        ///
        /// - Parameters:
        ///   - high: Drop the high roll values.
        ///   - count: The number of rolls to drop.
        public init(high: Bool = false, count: Int = 1) {
            self.high = high
            self.count = count
        }

        private var sortFunction: (RollResult, RollResult) -> Bool {
            if high {
                return { $0 > $1 }
            }
            else {
                return { $0 < $1 }
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
            var output = Array(results)
            for index in output.minIndices(count: count, sortedBy: sortFunction) {
                output[index].dropped = true
                output[index].modifiers.append(self)
            }
            return output
        }

        /// A string describing the operator in terms that can be parsed by
        /// the dice roller, e.g. `"dl1"`
        public var description: String {
            "d\(high ? "h" : "l")\(count)"
        }
    }
}
