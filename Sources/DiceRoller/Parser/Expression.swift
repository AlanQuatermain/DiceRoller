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

/// A single parsed expression, whether a roll, an integer, or an
/// arithmetic operation.
public enum Expression {
    /// A static number.
    case number(Int)
    /// A roll of dice.
    case roll(Roll)
    /// The result of a roll, calculated by calling `Expression.rolled()`.
    case result([RollResult])
    /// An addition operation between the results of two expressions.
    indirect case addition(Expression, Expression)
    /// A subtraction operation between the results of two expressions.
    indirect case subtraction(Expression, Expression)
    /// A multiplication operation between the results of two expressions.
    indirect case multiplication(Expression, Expression)
    /// A division operation between the results of two expressions.
    indirect case division(Expression, Expression)
    /// A modulus (remainder) operation between the results of two expressions.
    indirect case modulus(Expression, Expression)
    /// A power (index) operation between the results of two expressions.
    indirect case power(Expression, Expression)
    /// A single braced (parenthesized) expression.
    indirect case braced(Expression)
    /// A parser error.
    indirect case error(Error, Expression?)
}

extension Expression: Equatable {
    public static func == (lhs: Expression, rhs: Expression) -> Bool {
        switch (lhs, rhs) {
        case let (.number(l), .number(r)):
            return l == r
        case let (.roll(l), .roll(r)):
            return l == r
        case let (.result(l), .result(r)):
            return l == r
        case let (.addition(ll, lr), .addition(rl, rr)):
            return ll == rl && lr == rr
        case let (.subtraction(ll, lr), .subtraction(rl, rr)):
            return ll == rl && lr == rr
        case let (.multiplication(ll, lr), .multiplication(rl, rr)):
            return ll == rl && lr == rr
        case let (.division(ll, lr), .division(rl, rr)):
            return ll == rl && lr == rr
        case let (.modulus(ll, lr), .modulus(rl, rr)):
            return ll == rl && lr == rr
        case let (.power(ll, lr), .power(rl, rr)):
            return ll == rl && lr == rr
        case let (.braced(l), .braced(r)):
            return l == r
        case let (.error(le, lx), .error(re, rx)):
            return lx == rx && String(describing: le) == String(describing: re)
        default:
            return false
        }
    }
}

extension Expression: CustomStringConvertible {
    /// A description of the expression, suitable for printing.
    ///
    /// For an un-rolled expression, this will generate a string
    /// similar to the parser input; it will contain any defaults for
    /// optional values understood by any modifiers used.
    ///
    /// For a rolled expression, this will show the values of results
    /// in a bracketed list with modifier flags applied, e.g.
    /// `[4!d, 5, 1d, 3d]`.
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
    /// Prints out the expression tree rooted at this expression in a
    /// Lisp-style format.
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
    /// Computes the final value of a roll, combining values for any dice
    /// and applying all arithmetic modifiers.
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
