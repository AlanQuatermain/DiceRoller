//
//  File.swift
//  File
//
//  Created by Jim Dovey on 9/11/21.
//

import CitronParserModule
import CitronLexerModule

extension Expression {
    /// Performs the roll for all dice in the tree rooted at this expression,
    /// and returns a new expression containing the results, along with any non-roll
    /// expressions from the tree.
    ///
    /// - Returns: A new `Expression` containing the results of
    /// any dice rolls, with modifiers applied.
    public func rolled() -> Expression {
        switch self {
        case .number, .result, .error:
            return self
        case let .roll(r):
            return .result(r.roll())
        case let .addition(lhs, rhs):
            return .addition(lhs.rolled(), rhs.rolled())
        case let .subtraction(lhs, rhs):
            return .subtraction(lhs.rolled(), rhs.rolled())
        case let .multiplication(lhs, rhs):
            return .multiplication(lhs.rolled(), rhs.rolled())
        case let .division(lhs, rhs):
            return .division(lhs.rolled(), rhs.rolled())
        case let .modulus(lhs, rhs):
            return .modulus(lhs.rolled(), rhs.rolled())
        case let .power(lhs, rhs):
            return .power(lhs.rolled(), rhs.rolled())
        case let .braced(expr):
            return .braced(expr.rolled())
        }
    }

    /// Obtains the content of all `.result` expressions in the tree
    /// rooted at this expression, in order.
    ///
    /// - Returns: An array of `RollResult` instances describing
    /// the results of the rolls contained within this expression.
    public func collectRolls() -> [[RollResult]] {
        switch self {
        case .number, .error, .roll:
            return []
        case let .result(rolls):
            return [rolls]
        case let .braced(expr):
            return expr.collectRolls()
        case let .addition(lhs, rhs), let .subtraction(lhs, rhs),
                let .multiplication(lhs, rhs), let .division(lhs, rhs),
                let .modulus(lhs, rhs), let .power(lhs, rhs):
            return lhs.collectRolls() + rhs.collectRolls()
        }
    }
}

/// Provides the implementation of the dice expression parser and roller.
///
/// While it is entirely possible to use the `Dice`, `Roll`, and `Modifier`
/// types directly to construct dice chains and determine results, the simplest
/// and most direct route is to provide a dice expression as a `String`. This
/// class encapsulates the dice expression parser and rolls for you, providing
/// results in a variety of different formats.
public class DiceRoller {
    /// Errors that may occur while parsing.
    public enum Error: Swift.Error {
        /// An error occurred parsing the string; an unexpected character was encountered.
        /// Contains the index of the error in the input, and a descriptive string suitable for
        /// printing to the console.
        case tokenizationError(String.Index, String)

        /// The input ended unexpectedly.
        case unexpectedEOF

        /// Some other error occurred.
        case unknown(Swift.Error)
    }

    struct StdOutStream: TextOutputStream {
        func write(_ string: String) {
            print(string)
        }
    }

    public var output: TextOutputStream = StdOutStream()

    /// Create a new `DiceRoller` instance.
    public init() {}

    /// Parses an input string into an expression tree.
    ///
    /// The resulting `Expression` consists of a tree of parsed nodes describing
    /// the dice being rolled, any modifiers applied, and any arithmetic operations.  To
    /// actually roll the dice, call `Expression.rolled()` on this expression,
    /// which will replace any `.roll` expressions with `.result`s containing
    /// the values of the dice, along with modifier results.  A final computed value
    /// can be obtained by calling `Expression.computedValue` on the
    /// rolled expression.
    ///
    /// - Parameter input: The input dice roll string, such as `"4d6+3"`.
    /// - Returns: An `Expression` parsed from the input.
    public func decodeExpression(from input: String) throws -> Expression {
        let lexer = CitronLexer<LexerTokenData>(rules: lexingRules)
        let parser = DiceRollParser()
        let errorReporter = ErrorReporter(input: input, output: output)
        parser.errorCaptureDelegate = errorReporter

        do {
            try lexer.tokenize(input) {
                try parser.consume(token: (token: $0.token, position: lexer.currentPosition), code: $0.code)
            } onError: {
                try parser.consume(lexerError: $0)
            }
            errorReporter.endOfInputPosition = lexer.currentPosition
            return try parser.endParsing()
        }
        catch CitronLexerError.noMatchingRuleAt(let pos) {
            throw Error.tokenizationError(pos.tokenPosition, errorReporter.errorMessages[pos.tokenPosition] ?? "<none>")
        }
        catch is DiceRollParser.UnexpectedEndOfInputError {
            throw Error.unexpectedEOF
        }
        catch {
            throw Error.unknown(error)
        }
    }

    /// Parses an input roll expression and returns the results the dice rolls themselves.
    ///
    /// This will return only the roll results, ignoring any arithmetic operations.  In the cases
    /// where you aren't using arithmetic, this method will give you a quicker way to access
    /// the actual rolled die values.
    ///
    /// - Parameter input: The input dice roll string, such as `"4d6+3"`.
    /// - Returns: An array of `RollResult` instances representing the
    /// results of each rolled group of dice, including the effects of any modifiers
    /// used.
    public func roll(input: String) throws -> [[RollResult]] {
        let expression = try decodeExpression(from: input)
        return expression.rolled().collectRolls()
    }

    /// Parses an input roll expression and returns textual representations of the input and
    /// the rolled dice, along with the final numeric value.
    ///
    /// This method returns a tuple of `(input, rolled, value)`, where `input`
    /// is a text representation of the input as understood by the parser, `rolled` is a
    /// text representation of the output suitable for printing, and `value` is the
    /// integer value obtained by rolling the dice and applying all modifiers and
    /// arithmetic operations.
    ///
    /// Note that the returned `input` may not match the value passed in as a
    /// parameter; it shows the complete roll specification as understood by the
    /// parser, and as such includes any optional characters that may have been
    /// omitted in the original.
    ///
    /// The `rolled` output provides a string representation of the rolled dice
    /// that is appropriate for display to the user. The output format matches that
    /// used by [RPG Dice Roller](https://greenimp.github.io/rpg-dice-roller/)
    /// and [Roll20](https://roll20.net).
    ///
    /// For example:
    /// ```
    /// let input, rolled, value = roller.parse(input: "4d6k+3")
    /// print("\(input): \(rolled) = \(value)")
    /// ```
    ///
    /// ...might print:
    /// ```
    /// $ 4d6kh1+3: [4d, 3d, 1d, 5]+3 = 8
    /// ```
    ///
    /// - Parameter input: The input dice roll string, such as `"4d6+3"`.
    /// - Returns: The understood input, a printable description of the output, and
    /// the final numeric value of the full roll.
    public func parse(input: String) throws -> (input: String, rolled: String, value: Int) {
        let expression = try decodeExpression(from: input)
        let rolled = expression.rolled()
        return (expression.description, rolled.description, rolled.computedValue)
    }
}
