# DiceRoller

A Swift library implementing a dice roller with various modifiers and mathematical operators.

## Usage

The simplest way to roll dice is to use create a `DiceRoller` and call its `parse(input:)` method
to obtain a tuple containing the parsed input, the roll results, and the final sum:

```swift
import DiceRoller

let roller = DiceRoller()
let (parsed, rolled, total) = try roller.parse(input: "2d8 + 2 + 1d4")
print("\(parsed): \(rolled) = \(total)")
```

The above code would output something like the following:

```
2d8+2+1d4: [7, 2]+2+[3] = 14
```

A more involved method of making the roll would be to call `DiceRoller.decodeExpression(from:)`.
This would return an `Expression` instance, the root of a tree of expressions.

Once you have an `Expression`, you can access a Lisp-style representation of the expression
tree using `Expression.debugDescription`. Similarly `Expression.description` will yield
the parsed version of the input---including any inferred values.

To roll the dice, you can call `Expression.rolled()` to obtain a new expression tree in which
all dice groups have been rolled, and their outputs grouped in square braces (`[]`). Any
modifiers will have been applied at this point; they will leave flags on any dice values they
affected.

Lastly, the total of the roll can be obtained by calling `Expression.computedValue`. This will
sum the dice rolled (or the number of successes, depending on the modifiers used), and will
perform any mathematical operations included in the input to yield a final value.

## Adding `DiceRoller` as a Dependency

To use the `DiceRoller` library in a SwiftPM project,
add it to the dependencies for your package and your command-line executable target:

```swift
let package = Package(
    // name, platforms, products, etc.
    dependencies: [
        // other dependencies
        .package(url: "https://github.com/AlanQuatermain/DiceRoller", .branch("main")),
    ],
    targets: [
        .executableTarget(name: "<command-line-tool>", dependencies: [
            // other dependencies
            .product(name: "DiceRoller", package: "DiceRoller")
        ]),
        // other targets
    ]
)
```
