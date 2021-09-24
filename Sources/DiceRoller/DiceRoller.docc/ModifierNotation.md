# Modifier Notation

Modifiers allow you to change the value of dice rolls, set targets, and even
re-roll or add additional dice to your rolls.


Multiple modifiers can be applied to a single roll, and they will usually behave
well together.  As an example, `5d10!k2` will both [Explode](#Exploding) any maximum rolls
and [Keep](#Keep) only the highest 2 rolls from the result.

> Important: Modifiers always run in a specific order, regardless the order they're specified in.  This is determined by the modifier's ``Modifier/order-u7vo`` property, and works in ascending order.  As an example, `4d6!d1` and `4d6d1!` are equivalent, and the explode modifier will always run before the drop modifier.

## Modifiers

### Minimum

- term Syntax: `min{n}`
- term Order: 1

The `min` modifier causes any die rolls below a set minimum to be rounded up to
the given value. It is the opposite of the [Maximum](#Maximum) modifier.

To specify a minimum value, use the word `min` followed by the minimum value 
desired, e.g. `3d6min3`.

##### Examples

Roll | Result | Description
--- | --- | ---
`3d6` | `[1, 6, 1] = 8` | A normal roll
`3d6min3` | `[3^, 6, 3^] = 12` | The same roll, but values less than 3 are rounded up

> Note: This modifier increases the statistical likelihood of rolling the minimum value.  For example, in `d6min3`, there is a 1 in 6 chance of rolling a 4, 5, or 6, but a *3 in 6* or 50% chance of rolling a 3.

### Maximum

- term Syntax: `max{n}`
- term Order: 2

The `max` modifier causes any die rolls above a set maximum to be rounded down
to the given value. It is the opposite of the [Minimum](#Minimum) modifier.

To specify a maximum value, use the word `max` followed by the maximum value 
desired, e.g. `3d6max3`.

##### Examples

Roll | Result | Description
--- | --- | ---
`3d6` | `[6, 5, 3] = 14` | A normal roll
`3d6max3` | `[3v, 3v, 3] = 9` | The same roll, but values above 3 are rounded down

> Note: This modifier increases the statistical likelihood of rolling the maximum value.  For example, in `d6max3`, there is a 1 in 6 chance of rolling a 1 or 2, but a *4 in 6* or 66.6% chance of rolling a 3.

### Exploding

- term Syntax: `!` or `!{cp}`
- term Order: 3

Exploding dice allow one or more dice to be re-rolled (usually upon rolling the
highest value on the die), with each additional roll be added to the total.

To use an exploding die, use an exclamation mark, e.g. `4d10!`

Each exploded die will appear as an additional roll in the results:

```
2d6!: [5, 6!, 6!, 4] = 21
```

In this example, the second die rolled the highest value and thus exploded. The
additional die then rolled the highest value again, and so another die was
rolled, bringing the total count to 4.  The last roll did not explode, so the
roll ended there.

By default, dice explode when they roll their maximum value.  To change the 
value at which they explode, you can use a [comparison point](#Comparison-Points).

##### Examples

Roll | Description
--- | ---
`2d6!` | Explode on rolls equal to the die's upper bound
`2d6!=5` | Explode on rolls equal to 5
`2d6!>4` | Explode on rolls greater than 4
`4d10!<=3` | Explode on any roll less than or equal

> Note: To stop infinite loops when running an operation such as `d10!>0`, all
modifiers have a hard limit of 1000 iterations per die roll.
> 
> - `1d10!>0` would make 1001 rolls; the initial roll and 1000 explosions.
> - `2d10!>0` would make 2002 rolls; the initial 2 rolls and 1000 explosions each.
>
> This also applies to the [Compounding](#Compounding), [Penetrating](#Penetrating), and [Re-Roll](#Re-Roll) modifiers.

### Compounding

- term Syntax: `!!` or `!!{cp}`
- term Order: 3

Sometimes the rules call for exploded dice to be added together, for example
when the roll has a high target value impossible except with compounded rolls.
In this situation, you can compound the dice by using two exclamation marks 
instead of one: `3d6!!`.

Where exploding rolls additional dice:

```
3d6!: [5, 6!, 6!, 6!, 1, 4] = 28
```

...compounding sums the re-rolled dice:

```
3d6!!: [5, 19!!, 4] = 28
```

##### Examples

Roll | Description
--- | ---
`2d6!!` | Compound on rolls equal to the die's upper bound
`2d6!!=5` | Compound on rolls equal to 5
`2d6!!>4` | Compound on rolls greater than 4
`4d10!!<=3` | Compound on any roll less than or equal to 3

### Penetrating

- term Syntax: `!p` or `!p{cp}`
- term Order: 3

Some exploding dice systems use a "penetrating" rule.  Under this rule, new dice
are rolled as for regular [Exploding](#Exploding) dice, but the value of any
additional dice rolled are reduced by 1.

From the Hackmaster Basic rules:

> Should you roll the maximum value on this particular die, you may re-roll and
> add the result of the extra die, less one point, to the total (penetration can
> actually result in simply the maximum die value if a 1 is subsequently rolled,
> since any fool knows that 1-1=0). This process continues indefinitely as long
> as the die in question continues to come up maximum (but there’s always only a
> –1 subtracted from the extra die, even if it’s, say, the third die of
> penetration)

Additional rolls are checked for explosion before their values are reduced. If a
roll of `1d6!p` rolled a 6, another d6 would be rolled, subtracting 1 from the
result. If the new die also rolled a 6, it would also penetrate, though its 
value would be recorded as 5 in the result.

```
# Actual rolls are [6, 6, 6, 4, 1]
2d6!p: [6!p, 5!p, 5!p, 3, 1] = 20
```

As with the other exploding dice modifiers, you can use a
[comparison point](#Comparison-Points) to adjust the explosion criteria.

Roll | Description
--- | ---
`2d6!p` | Penetrate rolls equal to the die's upper bound
`2d6!p=5` | Penetrate on rolls equal to 5
`2d6!p>4` | Penetrate on rolls greater than 4
`2d6!p<=3` | Penetrate on rolls less than or equal to 3

### Re-roll

- term Syntax: `r`, `ro`, `r{cp}`, or `ro{cp}`
- term Order: 4

This modifier will re-roll any die that rolls its lowest possible value (usually
a 1). By default, it will re-roll until a value greater than the minimum is
rolled, discarding any previous rolls. This is similar to [Exploding](#Exploding)
dice, but where explosions add together all the dice rolled, the re-roll
modifier keeps only the final roll.

To re-roll the lowest value until a better value appears, append an `r` to the
dice expression:

```
1d6r: [4r] = 4
```

To re-roll only once, even if the re-roll returns the minimum value, use the 
`ro` form of notation:

```
1d6ro: [1ro] = 1
```

You can also use a [comparison point](#Comparison-Points) to set the condition
for re-rolling a die.

##### Examples

Roll | Description
--- | ---
`2d6r` | Re-roll rolls of 1 until a 2 or greater is rolled
`2d6r=5` | Re-roll on any rolls equal to 5
`2d6ro>4` | Re-roll once on rolls greater than 4
`4d10r<=3` | Re-roll any rolls less than or equal to 3

> Note: To prevent infinite loops when running an operation such as `d10!>0`, all
> modifiers have a hard limit of 1000 iterations per die roll.
> 
> - `1d10r>0` would only re-roll 1000 times.
> - `2d10!>0` would re-roll 2000 times---once for each initial roll.
>
> This also applies to the [Exploding](#Exploding), [Compounding](#Compounding), and [Penetrating](#Penetrating) modifiers.

### Keep

- term Syntax: `k{n}`, `kh{n}`, or `kl{n}`
- term Order: 5

The keep modifier lets you select a subset of your rolled dice to count towards
your total, ignoring the rest. It is the opposite of the [Drop](#Drop) modifier.

The notation for the keep modifier is a lowercase `k` followed by the type of
rolls that should be dropped (`h` for "highest" and `l` for "lowest") and the
number of dice to drop. The type is optional, and if omitted will default to
"highest."

In the output of the roll, the dropped values are still present, but are marked
with the `d` flag and do not count toward the roll's total:

```
6d8k3: [8, 5d, 7, 4d, 6d, 7] = 22
```

##### Examples

Roll | Description
--- | ---
`4d10kh2` | Roll 4 ten-sided dice and keep the highest 2 rolls
`4d10k2` | Equivalent to `4d10kh2`
`4d10kl1` | Roll 4 ten-sided dice and keep the lowest roll

> Note: The keep and [drop](#Drop) modifiers work together, but both will look
> at the entire dice pool.  So if a roll has been dropped, it will still be
> included in the list of possible rolls to drop, meaning that the keep and drop
> modifiers can override one another.
>
> For example:
>
> ```
> 3d10h1dh1: [7d, 1d, 2d] = 0
> ```
> 
> The `k1` dropped the 1 and 2, and the `dh1` dropped the 7.
>
> If you're careful you can use the pair in concert though, for instance to
> keep only the middle value:
>
> ```
> 3d10k2dh1: [4d, 8, 9d] = 8
> ```

### Drop

- term Syntax: `d{n}`, `dh{n}`, `dl{n}`
- term Order: 6

When you want to remove a certain number of high or low rolls from a pool of
dice, you would use this modifier. It is the opposite of the [Keep](#Keep)
modifier.

The notation for the drop modifier is a lowercase `d` followed by the type of
roll to be dropped (`h` for "highest," `l` for "lowest") and the number of dice
to drop. If the type is omitted, it will default to "lowest."

In the output of the roll, the dropped values are still present, but are marked
with the `d` flag and do not count toward the roll's total:

```
6d8dh3: [3, 5d, 6d, 1, 4, 7d] = 8
```

##### Examples

Roll | Description
--- | ---
`4d10dl2` | Roll 4 ten-sided dice and drop the lowest 2 rolls
`4d10k2` | Equivalent to `4d10dl2`
`4d10dh1` | Roll 4 ten-sided dice and drop the highest roll

> Note: See the note in the [Keep modifier section](#Keep) for information on
> using the keep and drop modifiers together.

### Target success / Dice pool

- term Syntax: `{cp}`
- term Order: 7

Several RPG systems, for instance [Tales from the Loop](https://loop-rpg.com)
and [Coriolis](https://coriolis-rpg.com), use a dice-pool mechanic where several
dice are rolled and each die that meeds a condition is considered a success.
Thus when rolling eight six-sided dice, you can achieve a score of zero to
eight, rather than the normal eight to forty-eight.

To make rolls of this type, you simply add a [comparison point](#Comparison-Points)
directly following the die notation. Dice that meet the comparison criteria are
marked with an `*` flag in the output. Any dice used with this modifier now have
a value of zero or one.

As an example, if you wanted to roll a pool of five ten-sided dice with a
success target of 8 or higher, you would use:

```
5d10>=8: [4, 5, 1, 9*, 10*] = 2
```

##### Examples

Roll | Result | Description
--- | --- | ---
`2d6=6` | `[4, 6*] = 1` | Only a roll of 6 is a success
`4d3>1` | `[1, 3*, 2*, 1] = 2` | Greater than 1 is a success
`4d3<2` | `[1*, 3, 2, 1*] = 2` | Less than 2 is a success
`5d8>=5` | `[2, 4, 6*, 3, 8*] = 2` | Greater than or equal to 5 is a success
`6d10<=4` | `[7, 2*, 10, 3*, 3*, 4*] = 4` | Less than or equal to 4 is a success

> Tip: A caveat to using the target modifier is that it cannot directly follow
> any modifier that optionally uses `[comparison points](#Comparison-Points)`,
> as the target modifier will be interpreted as the comparison point for the
> prior modifier:
>
> ```
> 2d6!>3: [3, 5!, 4!, 4!, 5!, 5!, 3] = 29
> ```
>
> You can work around this in a couple of ways. Firstly, you can put the target
> comparison point first:
>
> ```
> 2d6>3!: [1, 6!*, 4*] = 2
> ```
>
> Alternatively, you can explicitly specify the comparison point for the
> preceding modifier:
>
> ```
> 2d6!=6>3: [2, 6!*, 1] = 1
> ```

### Target Failures / Dice Pool

- term Syntax: `f{cp}`
- term Order: 7

Occasionally, when counting successes, you want to count failure conditions as
well; for example rolls of 8 or higher are successes, but rolls of 2 or lower
are failures, and count *against* the number of successes.

To make this type of roll, you can attach a Failure modifier immediately after
your success modifier, and any failures will be marked with the `_` flag:

```
4d6>4f<3: [4, 2_, 6*, 5*] = 1
```

> Important: A failure modifier *must* directly follow a success modifier.

##### Examples

Roll | Result | Description
--- | --- | ---
`2d6=6f<2` | `[4, 6*] = 1` | Only a roll of 6 is a success, less than 2 is a failure.
`5d8>=5f=1` | `[2, 4, 6*, 3, 8*] = 2` | Greater than or equal to 5 is a success, 1 is a failure
`6d10<=4f<5` | `[7, 2*, 10, 3*, 3*, 4*] = 4` | Less than or equal to 4 is a success, greater than 5 is a failure

### Critical Success

- term Syntax: `cs{cp}`
- term Order: 8

In several systems, rolling the maximum possible value on a die is considered a
"critical success," and this carries additional connotations. To call out a
critical success roll, you add `cs` and a [comparison point](#Comparison-Points) 
after the die notation, and matching rolls will be annotated with a `**` flag:

```
2d20cs=20: [1, 20**] = 21
```

> Tip: This modifier is purely aesthetic, and makes no functional difference to
> the rolls or their values.

##### Examples

Roll | Result | Description
--- | --- | ---
`4d10cs>7` | `[10**, 2, 6, 1] = 19` | Roll 4 ten-sided dice, anything above a 7 is a critical success
`2d20cs>=18` | `[12, 20**] = 32` | Roll 2 twenty-sided dice, 18 and above is a critical success

### Critical Failure

- term Syntax: `cs{cp}`
- term Order: 8

Similarly to [critical successes](#Critical-Success), rolling the lowest
possible value on a die is considered a "critical failure." To call out a
critical failure roll, you add `cf` and a [comparison point](#Comparison-Points) 
after the die notation, and matching rolls will be annotated with a `__` flag:

```
2d20cf=1: [1__, 20] = 21
```

> Tip: This modifier is purely aesthetic, and makes no functional difference to
> the rolls or their values.

##### Examples

Roll | Result | Description
--- | --- | ---
`4d10cf<3` | `[10, 2__, 6, 1__] = 19` | Roll 4 ten-sided dice, anything below 3 is a critical failure
`2d20cs<=2` | `[2__, 14] = 16` | Roll 2 twenty-sided dice, 2 or less is a critical failure

### Sorting

- term Syntax: `s`, `sa`, or `sd`
- term Order: 100

You can choose to have your dice rolls sorted, so that they are displayed in
ascending or descending numerical order, by appending the `s` modifier after the
dice notation, optionally followed by an `a` for "ascending" or `d` for
"descending." The default is "ascending" if no direction is specified.

##### Examples

Roll | Result | Description
--- | --- | ---
`4d6` | `[4, 3, 5, 1]` | No sorting
`4d6s` | `[1, 3, 4, 5]` | Sorts in ascending order by default
`4d6sa` | `[1, 3, 4, 5]` | Sort in ascending order
`4d6sd` | `[5, 4, 3, 1]` | Sort in descending order

## Comparison Points

Many modifiers activate when a die roll matches its highest or lowest value, but
in some cases you may want it to activate on another condition.  Comparison 
points provide the means to specify this information.

A comparison point is a comparative operator followed by a number to match
against:

Syntax | Operation
--- | ---
`=` | Equal to
`<>` | Not equal to
`<` | Less than
`<=` | Less than or equal to
`>` | Greater than
`>=` | Greater than or equal to

> Warning: At this time, this library does not support `!=` as a not-equal-to operator.  Please use `<>` instead.

The syntax is the same in any location a compare point can be used; these are
noted in the syntax declarations of modifiers using `{cp}`.

### Examples

```
# Roll a d6 and explode anything equal to 3
d6!=3

# Roll a d10 and explode on any roll greater than or equal to 5
d10!>=5

# Roll a d6 and compound on rolls greater than 4
d6!!>4

# Roll a d4 and re-roll anything less than 3
d4r<3
