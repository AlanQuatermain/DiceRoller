//
//  File.swift
//  File
//
//  Created by Jim Dovey on 9/11/21.
//

import CitronLexerModule
import CitronParserModule
import Foundation

enum Token {
    case punctuation
    case dieSpec(Int, Int)
    case fudgeSpec(Bool, Int)
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

    var count: Int {
        switch self {
        case let .dieSpec(count, _), let .fudgeSpec(_, count):
            return count
        default:
            return 0
        }
    }

    var lowFate: Bool {
        if case let .fudgeSpec(lowProb, _) = self {
            return lowProb
        }
        return false
    }

    var sides: Int {
        if case let .dieSpec(_, sides) = self {
            return sides
        }
        return 0
    }
}

typealias LexerTokenData = (token: Token, code: DiceRollParser.CitronTokenCode)
typealias Rule = CitronLexer<LexerTokenData>.LexingRule

let standardDieRegex = try! NSRegularExpression(pattern: "([1-9][0-9]*)?d([1-9][0-9]*)", options: [])
let percentDieRegex = try! NSRegularExpression(pattern: "([1-9][0-9]*)?d%", options: [])
let fateDieRegex = try! NSRegularExpression(pattern: "([1-9][0-9]*)?dF(?:\\.(1|2))?", options: [])

func getCountAndSize(from str: String, using regex: NSRegularExpression) -> (count: Int, size: Int)? {
    let range = NSRange(str.startIndex..., in: str)
    guard let match = regex.firstMatch(in: str, options: .anchored, range: range), (1...3).contains(match.numberOfRanges)
    else { fatalError("Lexer matched regex '\(regex.pattern)' to '\(str)', but I can't do the same?") }

    let countRange = match.range(at: 1)
    var count = 1
    var size = 100

    if match.numberOfRanges == 3, match.range(at: 2).location != NSNotFound {
        guard let sidesRange = Range(match.range(at: 2), in: str),
              let numSides = Int(str[sidesRange])
        else { return nil }

        size = numSides
    }

    if countRange.location != NSNotFound, let rng = Range(countRange, in: str), let value = Int(str[rng]) {
        count = value
    }

    return (count: count, size: size)
}

let lexingRules: [Rule] = [

    // Letter Tokens

    Rule.string("(",  (.punctuation, .OpenParen)),
    Rule.string(")",  (.punctuation, .CloseParen)),

    // Dice

    Rule.regex(standardDieRegex, {
        if let (count, size) = getCountAndSize(from: $0, using: standardDieRegex) {
            return (.dieSpec(count, size), .StandardDie)
        }
        return nil
    }),
    Rule.regex(percentDieRegex, {
        if let (count, _) = getCountAndSize(from: $0, using: percentDieRegex) {
            return (.integer(count), .PercentageDie)
        }
        return nil
    }),
    Rule.regex(fateDieRegex, {
        if let (count, size) = getCountAndSize(from: $0, using: fateDieRegex) {
            return (.fudgeSpec(size == 1, count), .FudgeDie)
        }
        return nil
    }),


    // Numbers

    Rule.regexPattern("[1-9][0-9]*", {
        guard let number = Int($0) else { return nil }
        return (.integer(number), .Integer)
    }),

    // Explode Modifier (has higher matching precedence than '!=')

    Rule.string("!!", (.modifierSpec, .Compound)),
    Rule.string("!p", (.modifierSpec, .Penetrate)),
    Rule.string("!",  (.modifierSpec, .Explode)),


    // Comparison Points

    Rule.string("=",  (.comparator, .Equal)),
//    Rule.string("!=", (.comparator, .NotEqual)), // SO MANY PRECEDENCE PROBLEMS !!
    Rule.string("<>", (.comparator, .NotEqual)),
    Rule.string(">=", (.comparator, .GreaterEqual)),
    Rule.string("<=", (.comparator, .LesserEqual)),
    Rule.string(">",  (.comparator, .Greater)),
    Rule.string("<",  (.comparator, .Lesser)),

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
    Rule.string("**", (.operator, .Power)),     // Ensure we recognize this before '*'
    Rule.string("*",  (.operator, .Multiply)),
    Rule.string("/",  (.operator, .Divide)),
    Rule.string("÷",  (.operator, .Divide)),
    Rule.string("%",  (.operator, .Modulo)),
    Rule.string("^",  (.operator, .Power)),


    // Whitespace is ignored

    Rule.regexPattern("\\s", { _ in nil }),
]


