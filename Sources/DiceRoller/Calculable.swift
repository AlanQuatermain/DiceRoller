//
//  Calculable.swift
//  DiceRoller
//
//  Created by Jim Dovey on 9/10/21.
//

/// Marks types that can produce a single integer value representing
/// their contents.
public protocol Calculable {
    /// The final calculated value of the receiver.
    var computedValue: Int { get }
}
