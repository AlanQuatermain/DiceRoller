//
//  RollResult.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/9/21.
//

public struct RollResult: Calculable {
    public var value: Int
    public var modifiers: [Modifier] = []
    public var dropped = false

    enum TargetCriteria {
        case success
        case failure
        case blank
        case value
    }

    var criteria: TargetCriteria = .value

    public var computedValue: Int {
        guard dropped == false else { return 0 }

        switch criteria {
        case .success:
            return 1
        case .failure:
            return -1
        case .blank:
            return 0
        case .value:
            return value
        }
    }

    var modifierFlags: String {
        modifiers.map { $0.flag }.joined()
    }
}

extension RollResult: CustomStringConvertible {
    public var description: String {
        "\(value)\(modifierFlags)"
    }
}

extension RollResult: Hashable {
    public static func == (lhs: RollResult, rhs: RollResult) -> Bool {
        lhs.value == rhs.value && lhs.dropped == rhs.dropped
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        modifiers.forEach { hasher.combine($0.name) }
        hasher.combine(dropped)
    }
}

extension RollResult: Comparable {
    public static func < (lhs: RollResult, rhs: RollResult) -> Bool {
        lhs.value < rhs.value
    }
}

extension Sequence where Element == RollResult {
    var value: Int {
        reduce(0) { $0 + ($1.dropped ? 0 : $1.value) }
    }
}

public struct ResultGroup: Calculable, CustomStringConvertible {
    public var results: [RollResult]

    public var description: String {
        String(describing: results.map(\.description))
    }

    public var computedValue: Int {
        results.map(\.computedValue).reduce(0, +)
    }
}
