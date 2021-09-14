//
//  Operators.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/10/21.
//

public struct Operator {
    public var symbol: String
    public var method: (Int, Int) -> Int

    public init(symbol: String, method: @escaping (Int, Int) -> Int) {
        self.symbol = symbol
        self.method = method
    }
}

extension Operator: CustomStringConvertible {
    public var description: String { symbol }
}

enum Operators {
    static var add = Operator(symbol: "+", method: +)
    static var subtract = Operator(symbol: "-", method: -)
    static var multiply = Operator(symbol: "*", method: *)
    static var divide = Operator(symbol: "/", method: /)
    static var modulus = Operator(symbol: "%", method: %)
    static var power = Operator(symbol: "^", method: ^)

    static func `operator`(for symbol: String) -> Operator? {
        switch symbol {
        case "+": return add
        case "-": return subtract
        case "*": return multiply
        case "/", "÷": return divide
        case "%": return modulus
        case "^", "**": return power
        default:
            return nil
        }
    }
}
