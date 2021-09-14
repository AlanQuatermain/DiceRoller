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
    public struct Keep: Modifier {
        public var name: String { "keep" }
        public var flag: String { "d" } // we attach to dropped rolls
        public var order: Int { 5 }

        public var high: Bool
        public var count: Int

        public init(high: Bool = true, count: Int = 1) {
            self.high = high
            self.count = count
        }

        public func run<R>(for results: R, using roll: () -> Int) -> [RollResult] where R : Sequence, R.Element == RollResult {
            var output = Array(results)
            for index in output.minIndices(count: output.count - count, sortedBy: <) {
                output[index].dropped = true
                output[index].modifiers.append(self)
            }
            return output
        }

        public var description: String {
            "k\(high ? "h" : "l")\(count)"
        }
    }

    public struct Drop: Modifier {
        public var name: String { "drop" }
        public var flag: String { "d" }
        public var order: Int { 6 }

        public var high: Bool
        public var count: Int

        public init(high: Bool = false, count: Int = 1) {
            self.high = high
            self.count = count
        }

        public func run<R>(for results: R, using roll: () -> Int) -> [RollResult] where R : Sequence, R.Element == RollResult {
            var output = Array(results)
            for index in output.minIndices(count: count, sortedBy: <) {
                output[index].dropped = true
                output[index].modifiers.append(self)
            }
            return output
        }

        public var description: String {
            "d\(high ? "h" : "l")\(count)"
        }
    }
}
