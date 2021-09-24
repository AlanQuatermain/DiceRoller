# About Dice Notation

While this library provides access to the structures and types it uses to manage
and roll dice internally, the main reason it exists is to allow the use of
standard dice notation to describe and make die rolls.

## Overview

Die rolling takes place by parsing a single expression in "dice notation,"
describing the dice to roll, any modifiers to apply, and any arithmetic
operations to perform on the results.

The format of the notation matches those used by the online
[RPG Dice Roller](https://greenimp.github.io/rpg-dice-roller/) and by
[Roll20](https://roll20.net), which are in turn based on a 
[Wikipedia Article](https://en.wikipedia.org/wiki/Dice_notation).  This syntax
is well known now, and forms an ad-hoc standard used in many different places.

### Types

There are several different types of notation supported by this library, which
can be broken down into the following groups:

- term <doc:DiceNotation>: Describes the different types of dice that can be
rolled and the available means to specify them.
- term <doc:ArithmeticOperators>: Lists the mathematical operations that can be
applied to the results of any rolls.
- term <doc:ModifierNotation>: Information on the different modifiers that you
can apply to your rolls.

