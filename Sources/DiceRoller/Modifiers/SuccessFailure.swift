//
//  SuccessFailure.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/10/21.
//

extension Modifiers {
    public struct Success: Modifier {
        public var name: String { "success" }
        public var flag: String { "*" }
        public var order: Int { 7 }

        public var comparison: ComparisonPoint

        public init(comparison: ComparisonPoint) {
            self.comparison = comparison
        }

        public var description: String {
            comparison.description
        }

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

    public struct Failure: Modifier {
        public var name: String { "failure" }
        public var flag: String { "_" }
        public var order: Int { 7 }

        public var comparison: ComparisonPoint

        public init(comparison: ComparisonPoint) {
            self.comparison = comparison
        }

        public var description: String {
            "f\(comparison)"
        }

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

    public struct CriticalSuccess: Modifier {
        public var name: String { "critical-success" }
        public var flag: String { "**" }
        public var order: Int { 8 }

        public var comparison: ComparisonPoint

        public init(comparison: ComparisonPoint) {
            self.comparison = comparison
        }

        public var description: String {
            "cs\(comparison)"
        }

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

    public struct CriticalFailure: Modifier {
        public var name: String { "critical-failure" }
        public var flag: String { "__" }
        public var order: Int { 9 }

        public var comparison: ComparisonPoint

        public init(comparison: ComparisonPoint) {
            self.comparison = comparison
        }

        public var description: String {
            "cf\(comparison)"
        }

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
