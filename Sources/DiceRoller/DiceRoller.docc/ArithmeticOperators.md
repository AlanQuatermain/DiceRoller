# Arithmetic Operators

This library supports a number of standard mathematical expressions.

### Operators

Standard arithmetic operators can be used to apply changes to the result of a
die roll:

Operation | Symbol | Alternate Symbol |
--- | --- | ---
Addition | `+` | |
Subtraction | `-` | | 
Multiplication | `*` | |
Division | `/` | `÷` |
Modulus | `%` | |
Power | `^` | `**` |

You can use these to modify roll results, or even to determine the number or
size of dice to roll:

- `(4-2)d10` --- Roll `4-2=2` ten-sided dice and sum the results.
- `3d(2*6)` --- Roll three `2*6=12`-sided dice and sum the results.
- `(d6)d8` --- Roll a six-sided die, then roll that many eight-sided dice,
summing the results.

### Parentheses

Parentheses are recognised anywhere in dice notation to group operations
together or to override operator precedence:

- `1d6+2*3` --- Results in `[4]+2*3 = [4]+6 = 10`.
- `(1d6+2)*3` --- Results in `([4]+2)*3 = 6*3 = 18`.
