//
//  File.swift
//  File
//
//  Created by Jim Dovey on 9/12/21.
//

import XCTest
@testable import DiceRoller

func describe(_ input: String, _ results: [RollResult]) -> String {
    "\(input): \(results) = \(results.reduce(0, { $0 + $1.computedValue }))"
}

func printResult(name: StaticString = #function, _ die: Dice, _ results: [RollResult]) {
    print("\(name) -- \(describe(die.description, results))")
}

func printResult(name: StaticString = #function, _ roll: Roll, _ results: [RollResult]) {
    print("\n\(name) -- \(describe(roll.description, results))\n\n")
}

class RollTests: XCTestCase {
    func testSingleDie() {
        let die = Dice.standard(sides: 6, count: 1)
        let result = die.rollAll()
        XCTAssertEqual(result.count, 1)
        printResult(die, result)
    }

    func testMultipleDice() {
        let die = Dice.standard(sides: 6, count: 4)
        let result = die.rollAll()
        XCTAssertEqual(result.count, 4)
        printResult(die, result)
    }

    func testPercentileDice() {
        let die = Dice.percent(count: 1)
        let result = die.rollAll()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(die.dieRange, 1...100)
        printResult(die, result)
    }

    func testFateDice() {
        let die = Dice.fate(lowProbability: false, count: 4)
        let result = die.rollAll()
        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result.allSatisfy({ (-1...1).contains($0.value) }))
    }
}
