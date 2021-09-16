//
//  File.swift
//  File
//
//  Created by Jim Dovey on 9/11/21.
//

import CitronParserModule
import CitronLexerModule

extension Expression {
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
        /// An error occurred when
        case tokenizationError(String.Index)
        case unexpectedToken(String)
        case unexpectedEOF

        case unknown(Swift.Error)
    }

    public struct StdOutStream: TextOutputStream {
        public func write(_ string: String) {
            print(string)
        }
    }

    public var output: TextOutputStream = StdOutStream()

    public init() {}

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
            throw Error.tokenizationError(pos.tokenPosition)
        }
        catch let err as DiceRollParser.UnexpectedTokenError {
            throw Error.unexpectedToken("\(err.tokenCode) (\(err.token))")
        }
        catch is DiceRollParser.UnexpectedEndOfInputError {
            throw Error.unexpectedEOF
        }
        catch {
            throw Error.unknown(error)
        }
    }

    public func roll(input: String) throws -> [[RollResult]] {
        let expression = try decodeExpression(from: input)
        return expression.rolled().collectRolls()
    }

    public func parse(input: String) throws -> (input: String, rolled: String, value: Int) {
        let expression = try decodeExpression(from: input)
        let rolled = expression.rolled()
        return (expression.description, rolled.description, rolled.computedValue)
    }
}
