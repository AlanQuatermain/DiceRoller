import XCTest
@testable import DiceRoller

final class DiceRollerTests: XCTestCase {
    func testExample() throws {
        let input = "5d5>3"
        let roller = DiceRoller()
        do {
            let (parsed, rolled, result) = try roller.parse(input: input)
            print("\n    \(parsed): \(rolled) = \(result)\n")
        }
        catch let err as DiceRoller.Error {
            switch err {
            case .tokenizationError(_, let str):
                print(str)
            case .unexpectedEOF:
                print("unexpected EOF")
            case .unknown(let e):
                print("unexpected error: \(e)")
            }
        }
    }
}
