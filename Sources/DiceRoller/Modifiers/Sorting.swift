//
//  Sorting.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/10/21.
//

extension Modifiers {
    public struct Sorting: Modifier {
        public var name: String { "sorting" }
        public var flag: String { "" }
        public var order: Int { Int.max } // always last

        let ascending: Bool

        public init(ascending: Bool = true) {
            self.ascending = ascending
        }

        public func run<R>(for results: R, using roll: () -> Int) -> [RollResult] where R : Sequence, R.Element == RollResult {
            ascending ? results.sorted(by: <) : results.sorted(by: >)
        }

        public var description: String {
            "s\(ascending ? "a" : "d")"
        }
    }
}
