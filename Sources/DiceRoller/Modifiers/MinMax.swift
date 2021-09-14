//
//  MinMax.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/10/21.
//

extension Modifiers {
    public struct Minimum: Modifier {
        public var name: String { "minimum" }
        public var flag: String { "^" }
        public let value: Int
        public var order: Int { 1 }

        public init(value: Int) {
            self.value = value
        }

        public func run<R>(for results: R, using roll: () -> Int) -> [RollResult] where R : Sequence, R.Element == RollResult {
            results.map {
                guard $0.value < value else { return $0 }
                return RollResult(value: value, modifiers: $0.modifiers + [self])
            }
        }

        public var description: String {
            "\(flag)\(value)"
        }
    }

    public struct Maximum: Modifier {
        public var name: String { "maximum" }
        public var flag: String { "v" }
        public let value: Int
        public var order: Int { 2 }

        public init(value: Int) {
            self.value = value
        }

        public func run<R>(for results: R, using roll: () -> Int) -> [RollResult] where R : Sequence, R.Element == RollResult {
            results.map {
                guard $0.value > value else { return $0 }
                return RollResult(value: value, modifiers: $0.modifiers + [self])
            }
        }

        public var description: String {
            "\(flag)\(value)"
        }
    }
}
