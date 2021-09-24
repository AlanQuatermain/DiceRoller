# ``DiceRoller/Expression``

## Overview

You can obtain expressions by creating a ``Roller`` and calling 
``Roller/decodeExpression(from:)``. The result is a tree of
Expression instances that you can inspect.

```swift
let expression = parser.decodeExpression(from: "3d6 + 1d8 * 2")
print(expression) // writes "3d6+1d8*2*"
print(expression.debugDescription) // writes "(+ 3d6 (* 1d8 2))"
```

The expressions initially contain the details of prospective dice rolls, but
these can be converted into the results of those rolls using
``Expression/rolled()``:

```swift
let rolledExpression = expression.rolled()
print(expression) // "[5, 5, 1]+[5]*2"
```

The total numerical value of a roll expression can be obtained using
``Expression/computedValue``:

```swift
print("\(expression) = \(expression.computedValue)") // [5, 5, 1]+[5]*2 = 21
```

## Topics

### Rolling Dice

- ``rolled()``
- ``collectDice()``
- ``collectRolls()``
- ``computedValue``

### String Representations

- ``description``
- ``debugDescription``

### Expression Types

- ``number(_:)``
- ``roll(_:)``
- ``result(_:)``
- ``addition(_:_:)``
- ``subtraction(_:_:)``
- ``multiplication(_:_:)``
- ``division(_:_:)``
- ``modulus(_:_:)``
- ``power(_:_:)``
- ``braced(_:)``
- ``error(_:_:)``
