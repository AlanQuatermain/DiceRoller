//
//  ErrorReporter.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/11/21.
//

import CitronLexerModule
import CitronParserModule

class ErrorReporter {
    let inputString: String
    var output: TextOutputStream
    var endOfInputPosition: CitronLexerPosition?
    var isErrorReportedAtEnd: Bool = false

    init(input: String, output: TextOutputStream) {
        self.inputString = input
        self.output = output
    }
}

struct ErrorModifier: Modifier {
    var name: String { "error" }
    var flag: String { "?" }

    func run<R>(for results: R, using roll: () -> Int) -> [RollResult] where R : Sequence, R.Element == RollResult {
        Array(results)
    }

    var description: String {
        "?"
    }
}

extension ErrorReporter: DiceRollParser.CitronErrorCaptureDelegate {
    typealias ErrorState = DiceRollParser.CitronErrorCaptureState
    typealias ErrorResponse = CitronErrorCaptureResponse
    typealias NonTerminal = DiceRollParser.CitronNonTerminalCode

    func shouldCaptureErrorOnRoot(state: DiceRollParser.CitronErrorCaptureState, error: Error) -> CitronErrorCaptureResponse<Expression> {
        reportError(error, on: .root, state: state)
        return .captureAs(.error(error, nil))
    }

    func shouldCaptureErrorOnExpr(state: DiceRollParser.CitronErrorCaptureState, error: Error) -> CitronErrorCaptureResponse<Expression> {
        reportError(error, on: .expr, state: state)
        return .captureAs(.error(error, findPartialExpression(from: state)))
    }

    func shouldCaptureErrorOnDice(state: DiceRollParser.CitronErrorCaptureState, error: Error) -> CitronErrorCaptureResponse<Dice> {
        reportError(error, on: .dice, state: state)
        return .dontCapture
    }

    func shouldCaptureErrorOnModifier(state: DiceRollParser.CitronErrorCaptureState, error: Error) -> CitronErrorCaptureResponse<Modifier> {
        reportError(error, on: .modifier, state: state)
        return .captureAs(ErrorModifier())
    }

    func shouldCaptureErrorOnCompare_point(state: DiceRollParser.CitronErrorCaptureState, error: Error) -> CitronErrorCaptureResponse<ComparisonPoint> {
        reportError(error, on: .compare_point, state: state)
        return .captureAs(ComparisonPoint(comparison: .greater, value: Int.max))
    }

    func findPartialExpression(from state: ErrorState) -> Expression? {
        return nil
    }
}

extension ErrorReporter {
    func reportError(_ error: Error, on symbol: NonTerminal, state: ErrorState) {
        if state.nextToken == nil {
            guard !isErrorReportedAtEnd else { return }
            isErrorReportedAtEnd = true
        }

        let lastResolvedSymbolCode = state.lastResolvedSymbol?.symbolCode
        let errorPosition: CitronLexerPosition
        if case let CitronLexerError.noMatchingRuleAt(pos) = error {
            errorPosition = pos
        }
        else {
            errorPosition = state.erroringToken?.token.position ?? endOfInputPosition!
        }

        switch symbol {
        case .root, .expr:
            switch lastResolvedSymbolCode {
            case .Die?:
                croak("expected die size", at: errorPosition)
            case .dice?:
                croak("expected compare point, comma, or modifier", at: errorPosition)
            case .modifier?, .modifier_list?:
                croak("expected separator or closing brace following modifiers", at: errorPosition)
            case .OpenParen?:
                croak("invalid characters at start of expression", at: errorPosition)
            case .Add?, .Subtract?, .Multiply?, .Divide?, .Modulo?, .Power?:
                croak("expected integer following operator", at: errorPosition)
            case .Integer?:
                croak("expected die specifier or operator", at: errorPosition)
            default:
                croak("error tokenizing 'expr'; lastResolved=\(String(describing: lastResolvedSymbolCode))",
                      at: errorPosition)
            }
        case .dice:
            switch lastResolvedSymbolCode {
            default:
                croak("invalid die specification", at: errorPosition)
            }
        case .modifier:
            switch lastResolvedSymbolCode {
            case .Explode?, .Compound?, .Penetrate?:
                croak("invalid comparison point after explosion specifier", at: errorPosition)
            case .Fail?:
                croak("invalid failure comparison point", at: errorPosition)
            case .KeepHigh?, .KeepLow?:
                croak("expected number of dice to keep", at: errorPosition)
            case .DropHigh?, .DropLow?:
                croak("expected number of dice to drop", at: errorPosition)
            case .Min?, .Max?:
                croak("expected number", at: errorPosition)
            case .Reroll?, .RerollOnce?:
                croak("invalid reroll comparison point", at: errorPosition)
            case .Critical?, .Fumble?:
                croak("invalid critical comparison point", at: errorPosition)
            default:
                croak("unknown modifier; lastResolved=\(String(describing: lastResolvedSymbolCode))", at: errorPosition)
            }
        case .compare_point:
            switch lastResolvedSymbolCode {
            case .Equal?, .NotEqual?, .Greater?, .GreaterEqual?, .Lesser?, .LesserEqual?:
                croak("expected number to follow comparison operator", at: errorPosition)
            default:
                croak("expected operator; lastResolved=\(String(describing: lastResolvedSymbolCode))", at: errorPosition)
            }
        default:
            // shouldn't happen, since we only pass in the above types
            fatalError("Error on unexpected symbol \(symbol) following \(String(describing: lastResolvedSymbolCode)) at \(errorPosition):\n\(error)")
        }
    }

    func croak(_ message: String, at position: CitronLexerPosition) {
        output.write("Error: \(message).")
        let column = inputString.distance(from: inputString.startIndex, to: position.tokenPosition)
        let padding = String(repeating: " ", count: column)
        output.write(inputString)
        output.write("\(padding)^")
    }
}
