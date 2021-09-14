import XCTest
@testable import DiceRoller

final class DiceRollerTests: XCTestCase {
    func testExample() throws {
        let input = "4d6!>4"
        let roller = DiceRoller()
        do {
            let (parsed, rolled, result) = try roller.parse(input: input)
            print("\n    \(parsed): \(rolled) = \(result)\n")
        }
        catch let err as DiceRoller.Error {
            switch err {
            case .tokenizationError(let pos):
                let width = input.distance(from: input.startIndex, to: pos)
                let padding = String(repeating: " ", count: width)
                print(input)
                print("\(padding)^")
            case .unexpectedToken(let info):
                print("unexpected token: \(info)")
            case .unexpectedEOF:
                print("unexpected EOF")
            case .unknown(let e):
                print("unexpected error: \(e)")
            }
        }
    }
}
