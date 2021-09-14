//
//  File.swift
//  File
//
//  Created by Jim Dovey on 9/11/21.
//

import CitronLexerModule
import CitronParserModule

enum Token {
    case punctuation
    case dieSpec
    case modifierSpec
    case `operator`
    case comparator
    case integer(Int)

    var value: Int {
        if case let .integer(v) = self {
            return v
        }
        return 0
    }
}

typealias LexerTokenData = (token: Token, code: DiceRollParser.CitronTokenCode)
typealias Rule = CitronLexer<LexerTokenData>.LexingRule

let lexingRules: [Rule] = [
    // Numbers

    Rule.regexPattern("[1-9][0-9]*", {
        guard let number = Int($0) else { return nil }
        return (.integer(number), .Integer)
    }),

    // Letter Tokens

    Rule.string("(",  (.punctuation, .OpenParen)),
    Rule.string(")",  (.punctuation, .CloseParen)),

    // Dice

    Rule.string("d",  (.dieSpec, .Die)),
    Rule.string("%",  (.dieSpec, .Percent)),
    Rule.string("dF", (.dieSpec, .Fudge)),
    Rule.regexPattern("\\.(1|2)", {
        guard let num = Int(String($0.dropFirst(1))) else { return nil }
        return (.integer(num), .FateSides)
    }),

    // Explode Modifier

    Rule.string("!",  (.modifierSpec, .Explode)),
    Rule.string("!!", (.modifierSpec, .Compound)),
    Rule.string("!p", (.modifierSpec, .Penetrate)),

    // Target Modifiers (just the failure case has an extra token)

    Rule.string("f", (.modifierSpec, .Fail)),

    // Keep/Drop Modifiers

    Rule.string("kh", (.modifierSpec, .KeepHigh)),
    Rule.string("kl", (.modifierSpec, .KeepLow)),
    Rule.string("k",  (.modifierSpec, .KeepHigh)),
    Rule.string("dl", (.modifierSpec, .DropLow)),
    Rule.string("dh", (.modifierSpec, .DropHigh)),
    Rule.string("d",  (.modifierSpec, .DropLow)),

    // Min/Max Modifiers

    Rule.string("min", (.modifierSpec, .Min)),
    Rule.string("max", (.modifierSpec, .Max)),

    // Reroll Modifier

    Rule.string("ro", (.modifierSpec, .RerollOnce)),
    Rule.string("r",  (.modifierSpec, .Reroll)),

    // Critical Modifier

    Rule.string("cs", (.modifierSpec, .Critical)),
    Rule.string("cf", (.modifierSpec, .Fumble)),

    // Sorting Modifier

    Rule.string("sa", (.modifierSpec, .SortAscending)),
    Rule.string("sd", (.modifierSpec, .SortDescending)),
    Rule.string("s",  (.modifierSpec, .SortAscending)),


    // Math Operations

    Rule.string("+",  (.operator, .Add)),
    Rule.string("-",  (.operator, .Subtract)),
    Rule.string("*",  (.operator, .Multiply)),
    Rule.string("/",  (.operator, .Divide)),
    Rule.string("÷",  (.operator, .Divide)),
    Rule.string("%",  (.operator, .Modulo)),
    Rule.string("^",  (.operator, .Power)),
    Rule.string("**", (.operator, .Power)),


    // Comparison Points

    Rule.string("=",  (.comparator, .Equal)),
    Rule.string("!=", (.comparator, .NotEqual)),
    Rule.string("<>", (.comparator, .NotEqual)),
    Rule.string(">",  (.comparator, .Greater)),
    Rule.string(">=", (.comparator, .GreaterEqual)),
    Rule.string("<",  (.comparator, .Lesser)),
    Rule.string("<=", (.comparator, .LesserEqual)),


    // Whitespace is ignored

    Rule.regexPattern("\\s", { _ in nil }),
]


