//
//  File.swift
//  File
//
//  Created by Jim Dovey on 9/10/21.
//

// Thanks be to mklbtz on Stack Overflow: <https://stackoverflow.com/a/39021464>
fileprivate func pow<T: BinaryInteger>(_ base: T, _ power: T) -> T {
    func expBySq(_ y: T, _ x: T, _ n: T) -> T {
        precondition(n >= 0)
        if n == 0 {
            return y
        }
        else if n == 1 {
            return y * x
        }
        else if n.isMultiple(of: 2) {
            return expBySq(y, x*x, n/2)
        }
        else { // n is odd
            return expBySq(y * x, x * x, (n-1) / 2)
        }
    }
    return expBySq(1, base, power)
}

public enum Expression {
    case number(Int)
    case roll(Roll)
    case result([RollResult])
    indirect case addition(Expression, Expression)
    indirect case subtraction(Expression, Expression)
    indirect case multiplication(Expression, Expression)
    indirect case division(Expression, Expression)
    indirect case modulus(Expression, Expression)
    indirect case power(Expression, Expression)
    indirect case braced(Expression)
    indirect case error(Error, Expression?)
}

extension Expression: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .number(v):
            return "\(v)"
        case let .roll(r):
            return "\(r)"
        case let .result(r):
            return "\(r)"
        case let .addition(lhs, rhs):
            return "\(lhs)+\(rhs)"
        case let .subtraction(lhs, rhs):
            return "\(lhs)-\(rhs)"
        case let .multiplication(lhs, rhs):
            return "\(lhs)*\(rhs)"
        case let .division(lhs, rhs):
            return "\(lhs)/\(rhs)"
        case let .modulus(lhs, rhs):
            return "\(lhs)%\(rhs)"
        case let .power(lhs, rhs):
            return "\(lhs)^\(rhs)"
        case let .braced(expr):
            return "(\(expr))"
        case let .error(err, exp):
            return "Error: \(err)\nPartial: \(exp?.description ?? "<none>")"
        }
    }
}

extension Expression: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .number, .roll, .result:
            return description
        case let .addition(lhs, rhs):
            return "(+ \(lhs.debugDescription) \(rhs.debugDescription))"
        case let .subtraction(lhs, rhs):
            return "(- \(lhs.debugDescription) \(rhs.debugDescription))"
        case let .multiplication(lhs, rhs):
            return "(* \(lhs.debugDescription) \(rhs.debugDescription))"
        case let .division(lhs, rhs):
            return "(÷ \(lhs.debugDescription) \(rhs.debugDescription))"
        case let .modulus(lhs, rhs):
            return "(% \(lhs.debugDescription) \(rhs.debugDescription))"
        case let .power(lhs, rhs):
            return "(^ \(lhs.debugDescription) \(rhs.debugDescription))"
        case let .braced(expr):
            return "(braced \(expr))"
        case let .error(err, exp):
            return "Error: \(err)\nPartial: \(exp?.debugDescription ?? "<none>")"
        }
    }
}

extension Expression: Calculable {
    public var computedValue: Int {
        switch self {
        case let .number(v):
            return v
        case .roll:
            fatalError("Cannot derive a computed value from un-rolled dice")
        case let .result(r):
            return r.reduce(0) { $0 + $1.computedValue }
        case let .addition(lhs, rhs):
            return lhs.computedValue + rhs.computedValue
        case let .subtraction(lhs, rhs):
            return lhs.computedValue - rhs.computedValue
        case let .multiplication(lhs, rhs):
            return lhs.computedValue * rhs.computedValue
        case let .division(lhs, rhs):
            return lhs.computedValue / rhs.computedValue
        case let .modulus(lhs, rhs):
            return lhs.computedValue % rhs.computedValue
        case let .power(lhs, rhs):
            return pow(lhs.computedValue, rhs.computedValue)
        case let .braced(expr):
            return expr.computedValue
        case let .error(_, exp):
            return exp?.computedValue ?? 0
        }
    }
}
