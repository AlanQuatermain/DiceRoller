//
//  File.swift
//  File
//
//  Created by Jim Dovey on 9/13/21.
//

import ArgumentParser
import DiceRoller

@main
struct Roll: ParsableCommand {
    enum Style: String, ExpressibleByArgument {
        case short, regular, verbose
    }

    static var configuration = CommandConfiguration(abstract: "Rolls RPG-style dice.")

    @Option(name: .shortAndLong, help: .init("Output verbosity (short|regular|verbose).", discussion: "short: outputs only the sum of the roll.\nregular: outputs the individual dice results and the sum of the roll.\nverbose: outputs the parsed expression, dice results, and sum."))
    var outputStyle: Style = .regular

    @Flag(name: .shortAndLong, help: "Output the parsed expression tree in Lisp-like notation.")
    var debug = false

    @Argument(help: "The dice expression.")
    var expression: String

    func run() throws {
        let roller = DiceRoller()
        let expr = try roller.decodeExpression(from: expression)
        let rolled = expr.rolled()
        let value = rolled.computedValue

        if debug {
            print("EXPRESSION: \(expr.debugDescription)\n")
        }

        switch outputStyle {
        case .short: print(value)
        case .regular: print("\(rolled.description) = \(value)")
        case .verbose: print("\(expr.description): \(rolled.description) = \(value)")
        }
    }
}
