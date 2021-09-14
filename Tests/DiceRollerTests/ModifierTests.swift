//
//  File.swift
//  File
//
//  Created by Jim Dovey on 9/12/21.
//

import XCTest
@testable import DiceRoller
import Algorithms

func flagsMatch(_ flags: String) -> (RollResult) -> Bool {
    { $0.modifierFlags == flags }
}
func flagsMatchOrEmpty(_ flags: String) -> (RollResult) -> Bool {
    { $0.modifierFlags == flags || $0.modifierFlags.isEmpty }
}

class ModifierTests: XCTestCase {
    func testDropLow1() {
        let modifier = Modifiers.Drop()
        let roll = Roll(dice: .standard(sides: 6, count: 4), modifiers: [modifier])
        var result = roll.roll()
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result.filter({ $0.dropped }).count, 1)
        printResult(roll, result)

        let partitionIdx = result.partition { $0.modifiers.count > 0 }
        XCTAssertEqual(result[..<partitionIdx].count, 3)
        XCTAssertTrue(result[partitionIdx...].allSatisfy(flagsMatch("d")))
    }

    func testDropLow2() {
        let modifier = Modifiers.Drop(count: 2)
        let roll = Roll(dice: .standard(sides: 6, count: 4), modifiers: [modifier])
        var result = roll.roll()
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result.filter({ $0.dropped }).count, 2)
        printResult(roll, result)

        let partitionIdx = result.partition { $0.modifiers.count > 0 }
        XCTAssertEqual(result[..<partitionIdx].count, 2)
        XCTAssertTrue(result[partitionIdx...].allSatisfy(flagsMatch("d")))
    }

    func testKeepHigh1() {
        let modifier = Modifiers.Keep()
        let roll = Roll(dice: .standard(sides: 6, count: 4), modifiers: [modifier])
        var result = roll.roll()
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result.filter({ $0.dropped }).count, 3)
        printResult(roll, result)

        let partitionIdx = result.partition { $0.modifiers.count > 0 }
        XCTAssertEqual(result[..<partitionIdx].count, 1)
        XCTAssertTrue(result[partitionIdx...].allSatisfy(flagsMatch("d")))
    }

    func testKeepHigh2() {
        let modifier = Modifiers.Keep(count: 2)
        let roll = Roll(dice: .standard(sides: 6, count: 4), modifiers: [modifier])
        var result = roll.roll()
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result.filter({ $0.dropped }).count, 2)
        printResult(roll, result)

        let partitionIdx = result.partition { $0.modifiers.count > 0 }
        XCTAssertEqual(result[..<partitionIdx].count, 2)
        XCTAssertTrue(result[partitionIdx...].allSatisfy(flagsMatch("d")))
    }

    func testExplode() {
        var roll = Roll(dice: .standard(sides: 6, count: 2))
        roll.modifiers.append(Modifiers.Explode(for: roll.dice))
        var result: [RollResult] = []
        repeat {
            result = roll.roll()
        } while result.count == 2
        XCTAssertEqual(result.filter({ $0.modifiers.isEmpty }).count, 2)
        printResult(roll, result)

        let partitionIdx = result.partition { $0.modifiers.count > 0 }
        XCTAssertEqual(result[..<partitionIdx].count, 2)
        XCTAssertTrue(result[partitionIdx...].allSatisfy(flagsMatch("!")))
    }

    func testCompound() {
        var roll = Roll(dice: .standard(sides: 6, count: 2))
        roll.modifiers.append(Modifiers.Explode(for: roll.dice, format: .compounding))
        var result: [RollResult] = []
        repeat {
            result = roll.roll()
        } while result.firstIndex(where: { $0.modifiers.count > 0}) == nil
        printResult(roll, result)

        XCTAssertTrue(result.allSatisfy(flagsMatchOrEmpty("!!")))
    }

    func testPenetrating() {
        var roll = Roll(dice: .standard(sides: 6, count: 2))
        roll.modifiers.append(Modifiers.Explode(for: roll.dice, format: .penetrating))
        var result: [RollResult] = []
        repeat {
            result = roll.roll()
        } while result.firstIndex(where: { $0.modifiers.count > 0}) == nil
        printResult(roll, result)

        let partitionIdx = result.partition { $0.modifiers.count > 0 }
        XCTAssertEqual(result[..<partitionIdx].count, 2)
        XCTAssertTrue(result[partitionIdx...].allSatisfy(flagsMatch("!p")))
    }

    func testExplodeWithComparison() {
        var roll = Roll(dice: .standard(sides: 6, count: 2))
        let comparison = ComparisonPoint(comparison: .greater, value: 3)
        roll.modifiers.append(Modifiers.Explode(comparison: comparison))
        var result: [RollResult] = []
        repeat {
            result = roll.roll()
        } while result.count == 2
        XCTAssertEqual(result.filter({ $0.modifiers.isEmpty }).count, 2)
        printResult(roll, result)

        let partitionIdx = result.partition { $0.modifiers.count > 0 }
        XCTAssertEqual(result[..<partitionIdx].count, 2)
        XCTAssertTrue(result[partitionIdx...].allSatisfy(flagsMatch("!")))
    }

    func testReroll() {
        var roll = Roll(dice: .standard(sides: 6, count: 10))
        roll.modifiers.append(Modifiers.Reroll())
        var result: [RollResult] = []
        repeat {
            result = roll.roll()
        } while result.firstIndex(where: { $0.modifiers.count > 0}) == nil
        printResult(roll, result)

        let partitionIdx = result.partition { $0.modifiers.count > 0 }
        XCTAssertTrue(result[partitionIdx...].allSatisfy(flagsMatch("r")))
        XCTAssertNil(result.firstIndex(where: { $0.value == 1 }))
    }

    func testRerollWithComparison() {
        var roll = Roll(dice: .standard(sides: 6, count: 10))
        let comparison = ComparisonPoint(comparison: .lesserEqual, value: 3)
        roll.modifiers.append(Modifiers.Reroll(comparison: comparison))
        var result: [RollResult] = []
        repeat {
            result = roll.roll()
        } while result.firstIndex(where: { $0.modifiers.count > 0}) == nil
        printResult(roll, result)

        let partitionIdx = result.partition { $0.modifiers.count > 0 }
        XCTAssertTrue(result[partitionIdx...].allSatisfy(flagsMatch("r")))
        XCTAssertNil(result.firstIndex(where: { $0.value <= 3 }))
    }

    func testRerollOnce() {
        var roll = Roll(dice: .standard(sides: 6, count: 10))
        roll.modifiers.append(Modifiers.Reroll(once: true))
        var result: [RollResult] = []
        repeat {
            result = roll.roll()
        } while result.firstIndex(where: { $0.modifiers.count > 0}) == nil
        printResult(roll, result)

        let partitionIdx = result.partition { $0.modifiers.count > 0 }
        XCTAssertTrue(result[..<partitionIdx].allSatisfy({ $0.value > 1 }))
        XCTAssertTrue(result[partitionIdx...].allSatisfy(flagsMatch("ro")))
    }

    func testRerollOnceWithComparison() {
        var roll = Roll(dice: .standard(sides: 6, count: 10))
        let comparison = ComparisonPoint(comparison: .lesserEqual, value: 3)
        roll.modifiers.append(Modifiers.Reroll(once: true, comparison: comparison))
        var result: [RollResult] = []
        repeat {
            result = roll.roll()
        } while result.firstIndex(where: { $0.modifiers.count > 0}) == nil
        printResult(roll, result)

        let partitionIdx = result.partition { $0.modifiers.count > 0 }
        XCTAssertTrue(result[..<partitionIdx].allSatisfy({ $0.value > 3 }))
        XCTAssertTrue(result[partitionIdx...].allSatisfy(flagsMatch("ro")))
    }

    func testTargetSuccess() {
        var roll = Roll(dice: .standard(sides: 6, count: 8))
        let comparison = ComparisonPoint(comparison: .greaterEqual, value: 4)
        roll.modifiers.append(Modifiers.Success(comparison: comparison))
        var result: [RollResult] = []
        repeat {
            result = roll.roll()

        } while result.firstIndex(where: { $0.modifiers.count > 0}) == nil
        printResult(roll, result)

        let partitionIdx = result.partition { $0.modifiers.count > 0 }
        XCTAssertTrue(result[..<partitionIdx].allSatisfy({ $0.criteria == .blank }))
        XCTAssertTrue(result[partitionIdx...].allSatisfy({ $0.criteria == .success }))
        XCTAssertTrue(result[partitionIdx...].allSatisfy(flagsMatch("*")))

        let successes = result.reduce(0) { $0 + $1.computedValue }
        XCTAssertEqual(result.distance(from: partitionIdx, to: result.endIndex), successes)
    }

    func testTargetSuccessFailure() {
        var roll = Roll(dice: .standard(sides: 6, count: 8))
        let succeed = ComparisonPoint(comparison: .greaterEqual, value: 5)
        let fail = ComparisonPoint(comparison: .lesserEqual, value: 2)
        roll.modifiers.append(Modifiers.Success(comparison: succeed))
        roll.modifiers.append(Modifiers.Failure(comparison: fail))
        var result: [RollResult] = []
        repeat {
            result = roll.roll()

        } while result.firstIndex(where: { $0.criteria == .success }) == nil
            && result.firstIndex(where: { $0.criteria == .failure }) == nil
        printResult(roll, result)

        let partitionIdx = result.partition { $0.modifiers.count > 0 }
        XCTAssertTrue(result[..<partitionIdx].allSatisfy({ $0.criteria == .blank }))

        var modified = Array(result[partitionIdx...])
        let succFail = modified.partition { $0.criteria == .success }

        XCTAssertTrue(modified[..<succFail].allSatisfy({ $0.criteria == .failure }))
        XCTAssertTrue(modified[..<succFail].allSatisfy(flagsMatch("_")))

        XCTAssertTrue(modified[succFail...].allSatisfy({ $0.criteria == .success }))
        XCTAssertTrue(modified[succFail...].allSatisfy(flagsMatch("*")))

        let total = result.reduce(0) { $0 + $1.computedValue }
        let numFailures = modified.distance(from: modified.startIndex, to: succFail)
        let numSuccesses = modified.distance(from: succFail, to: modified.endIndex)

        XCTAssertEqual(numSuccesses - numFailures, total)
    }

    func testCriticals() {
        var roll = Roll(dice: .standard(sides: 6, count: 8))
        let succeed = ComparisonPoint(comparison: .greaterEqual, value: 5)
        let fail = ComparisonPoint(comparison: .lesserEqual, value: 2)
        roll.modifiers.append(Modifiers.CriticalSuccess(comparison: succeed))
        roll.modifiers.append(Modifiers.CriticalFailure(comparison: fail))
        var result: [RollResult] = []
        repeat {
            result = roll.roll()

        } while result.firstIndex(where: { $0.modifierFlags == "**" }) == nil
            && result.firstIndex(where: { $0.modifierFlags == "__" }) == nil
        printResult(roll, result)

        let partitionIdx = result.partition { $0.modifiers.count > 0 }
        XCTAssertTrue(result[..<partitionIdx].allSatisfy({ (3...4).contains($0.value) }))

        var modified = Array(result[partitionIdx...])
        let succFail = modified.partition { $0.modifiers[0] is Modifiers.CriticalSuccess }

        XCTAssertTrue(modified[..<succFail].allSatisfy({ $0.value <= 2 }))
        XCTAssertTrue(modified[..<succFail].allSatisfy(flagsMatch("__")))

        XCTAssertTrue(modified[succFail...].allSatisfy({ $0.value >= 5 }))
        XCTAssertTrue(modified[succFail...].allSatisfy(flagsMatch("**")))

        // Crit flags don't affect the actual numeric outcome
        let total = result.reduce(0) { $0 + $1.value }
        let computed = result.reduce(0) { $0 + $1.computedValue }
        XCTAssertEqual(total, computed)
    }

    func testSortAscending() {
        var roll = Roll(dice: .standard(sides: 6, count: 10))
        roll.modifiers.append(Modifiers.Sorting(ascending: true))
        let result: [RollResult] = roll.roll()
        printResult(roll, result)

        XCTAssertTrue(result.allSatisfy({ $0.modifiers.isEmpty }))
        for item in result.adjacentPairs() {
            XCTAssertLessThanOrEqual(item.0, item.1)
        }
    }

    func testSortDescending() {
        var roll = Roll(dice: .standard(sides: 6, count: 10))
        roll.modifiers.append(Modifiers.Sorting(ascending: false))
        let result: [RollResult] = roll.roll()
        printResult(roll, result)

        XCTAssertTrue(result.allSatisfy({ $0.modifiers.isEmpty }))
        for item in result.adjacentPairs() {
            XCTAssertGreaterThanOrEqual(item.0, item.1)
        }
    }
}
