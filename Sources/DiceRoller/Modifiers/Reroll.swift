//
//  Reroll.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/10/21.
//

extension Modifiers {
    public struct Reroll: Modifier {
        public var name: String { "reroll" }
        public var flag: String { once ? "ro" : "r" }
        public var order: Int { 4 }

        public let once: Bool
        public let comparison: ComparisonPoint?

        public init(once: Bool = false, comparison: ComparisonPoint? = nil) {
            self.once = once
            self.comparison = comparison
        }

        public var description: String {
            if let comparison = comparison {
                return flag + "\(comparison)"
            }
            else {
                return flag
            }
        }

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
