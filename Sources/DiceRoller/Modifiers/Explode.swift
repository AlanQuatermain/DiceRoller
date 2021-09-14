//
//  Explode.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/9/21.
//

extension Modifiers {
    public struct Explode: Modifier {
        public var name: String { "explode" }
        public var flag: String {
            switch format {
            case .exploding: return "!"
            case .compounding: return "!!"
            case .penetrating: return "!p"
            }
        }
        public var order: Int { 3 }

        public var description: String {
            flag + comparison.operator
        }

        public enum Format {
            /// Add another roll result each time a roll matches the comparison.
            case exploding
            /// Roll again each time a roll matches the comparison, accumulating
            /// in a single result.
            case compounding
            /// Add another roll, but subtract 1 from the result of that roll.
            case penetrating
        }

        public private(set) var format: Format = .exploding
        public private(set) var comparison: ComparisonPoint

        public init(
            comparison: ComparisonPoint,
            format: Format = .exploding
        ) {
            self.comparison = comparison
            self.format = format
        }

        public init(
            for die: Dice,
            format: Format = .exploding
        ) {
            comparison = .init(maximumOf: die)
            self.format = format
        }

        public func run<R>(
            for results: R,
            using roller: Roller
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

        private func explode(roll: RollResult, using roller: Roller, subtract: Int = 0) -> [RollResult] {
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

        private func compound(roll: RollResult, using roller: Roller) -> [RollResult] {
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

        private func penetrate(roll: RollResult, using roller: Roller) -> [RollResult] {
            explode(roll: roll, using: roller, subtract: 1)
        }
    }
}
