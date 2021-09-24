# Dice Notation

The most basic---and essential---component of dice notation is the die roll
itself.

### Standard Dice

- term Syntax: `d{n}`

A standard die has a positive, non-zero number of sides, and can describe any
numbered die you've seen, and any you haven't.  The format used to specify your
dice is to use the lowercase letter `d` followed by the number of sides on the
die.  You can optionally put the number of dice to roll and sum in front of the
`d`, or leave off the count to roll a single die.

Roll | Result
--- | ---
`d6` | Rolls a single six-sided die.
`2d20` | Rolls two twenty-sided dice, summing their results.

### Percentile Dice

- term Syntax: `d%`

Percentile dice are 100-sided dice, and are often rolled with a pair of
ten-sided dice: one for the tens digit, and one for the units.  While these may
be written out as `d100`, the term `d%` has become an oft-used contraction.
This library uses a single [Zocchihedron](https://en.wikipedia.org/wiki/Zocchihedron)
roll for 100-sided dice, as with any other size.

Roll | Result
--- | ---
`d%` | Rolls a single hundred-sided die.
`2d%` | Rolls two hundred-sided dice, summing their results.
`2d100` | Rolls two hundred-sided dice, summing their results.

### Fate/Fudge Dice

- term Syntax: `dF`, `dF.1`, `dF.2`

Fate dice are six-sided dice with faces that are either blank or marked with a
`-` or a `+` symbol, corresponding to values of `0`, `-1`, and `1` respectively.
The default style of fate die has two of each side, and is usually written as
simply `dF`.  An alternate form has four blank sides and a single `-` and `+`;
this variant can be specified by using `dF.1`.  The standard fate die can be
specified using `dF.2` if desired.

Roll | Result
--- | ---
`dF` | Rolls a single standard fate die, equivalent to `dF.2`.
`dF.2` | Rolls a single standard fate die, equivalent to `dF`.
`dF.1` | Rolls a single variant fate die.
`4dF` | Rolls four standard fate dice, summing their results.
