//
//  Operations.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/9/21.
//

public protocol Modifier: CustomStringConvertible {
    var name: String { get }
    var flag: String { get }
    var order: Int { get }

    func run<R: Sequence>(for results: R, using roll: Roller) -> [RollResult] where R.Element == RollResult
}

extension Modifier {
    public var order: Int { 999 }
}

// namespace for our modifier types
public enum Modifiers {
    public static var iterationLimit = 1000
}

extension Sequence where Element == Modifier {
    func ordered() -> [Element] {
        sorted { $0.order < $1.order }
    }
}
