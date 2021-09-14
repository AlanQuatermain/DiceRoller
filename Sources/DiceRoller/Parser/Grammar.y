// Output type

%class_name DiceRollParser

// Current die size (used for max-roll comparisons)

%extra_class_members {
    var currentDieMax: Int = 6
}

// Import

%preface {
import CitronParserModule
import CitronLexerModule
}


// Type for terminals
%token_type "(token: Token, position: CitronLexerPosition)"

// Associativity/Precedence
%left_associative Explode Compound Penetrate Reroll RerollOnce Critical Fumble Sort.
%left_associative Equal NotEqual Greater GreaterEqual Lesser LesserEqual.

%left_associative Add Subtract.
%left_associative Multiply Divide Modulo.
%right_associative Power.

%left_associative Die.

%nonterminal_type expr Expression
%nonterminal_type expr_list "[Expression]"


//// Root of the output graph is a list of expression groups.
//
//%nonterminal_type root "[ExpressionGroup]"
//%nonterminal_type expr_group_list "[ExpressionGroup]"

%nonterminal_type root Expression
root ::= expr(a). { return a }
//root ::= expr_group_list(a). { return a }
//expr_group_list ::= expr_group(a). { return [a] }
//expr_group_list ::= expr_group(a) expr_group_list(b). { return [a] + b }


// Roll Groups

//%nonterminal_type expr_group ExpressionGroup
//
//expr_group ::= OpenBrace expr_list(a) CloseBrace. {
//    return ExpressionGroup(expressions: a)
//}
//expr_group ::= OpenBrace expr_list(a) CloseBrace modifier_list(mods). {
//    return ExpressionGroup(expressions: a, modifiers: mods)
//}


// Dice

%nonterminal_type dice Dice

dice ::= Integer(c) Die Integer(s). {
    currentDieMax = s.token.value
    return .standard(sides: s.token.value, count: c.token.value)
}
dice ::= Integer(c) Die Percent. {
    currentDieMax = 100
    return .percent(count: c.token.value)
}
dice ::= Integer(c) Die Fudge. {
    currentDieMax = 1
    return .fate(lowProbability: false, count: c.token.value)
}
dice ::= Integer(c) Die Fudge FateSides(v). {
    currentDieMax = 1
    return .fate(lowProbability: v.token.value == 1, count: c.token.value)
}


// Rolls (dice + modifiers)

%nonterminal_type roll Roll

roll ::= dice(d). {
    return Roll(dice: d)
}
roll ::= dice(d) modifier_list(mods). {
    return Roll(dice: d, modifiers: mods)
}


// Modifiers

%nonterminal_type modifier Modifier
%nonterminal_type modifier_list "[Modifier]"

// Explode

modifier ::= Explode. {
    let cp = ComparisonPoint(comparison: .maxRoll, value: currentDieMax)
    return Modifiers.Explode(comparison: cp, format: .exploding)
}
modifier ::= Explode compare_point(cp).  {
    return Modifiers.Explode(comparison: cp, format: .exploding)
}
modifier ::= Compound. {
    let cp = ComparisonPoint(comparison: .maxRoll, value: currentDieMax)
    return Modifiers.Explode(comparison: cp, format: .compounding)
}
modifier ::= Compound compare_point(cp). {
    return Modifiers.Explode(comparison: cp, format: .compounding)
}
modifier ::= Penetrate. {
    let cp = ComparisonPoint(comparison: .maxRoll, value: currentDieMax)
    return Modifiers.Explode(comparison: cp, format: .penetrating)
}
modifier ::= Penetrate compare_point(cp). {
    return Modifiers.Explode(comparison: cp, format: .penetrating)
}

// Target

modifier ::= compare_point(cp). {
    return Modifiers.Success(comparison: cp)
}
modifier_list ::= compare_point(scp) Fail compare_point(fcp). {
    return [
        Modifiers.Success(comparison: scp),
        Modifiers.Failure(comparison: fcp)
    ]
}

// Keep/Drop

modifier ::= KeepHigh. {
    return Modifiers.Keep(high: true, count: 1)
}
modifier ::= KeepHigh Integer(a). {
    return Modifiers.Keep(high: true, count: a.token.value)
}
modifier ::= KeepLow Integer(a). {
    return Modifiers.Keep(high: false, count: a.token.value)
}

modifier ::= DropLow. {
    return Modifiers.Drop(high: false, count: 1)
}
modifier ::= DropHigh Integer(a). {
    return Modifiers.Drop(high: true, count: a.token.value)
}
modifier ::= DropLow Integer(a). {
    return Modifiers.Drop(high: false, count: a.token.value)
}

// Min/Max

modifier ::= Min Integer(a). {
    return Modifiers.Minimum(value: a.token.value)
}
modifier ::= Max Integer(a). {
    return Modifiers.Maximum(value: a.token.value)
}

// Reroll

modifier ::= Reroll. {
    return Modifiers.Reroll()
}
modifier ::= Reroll compare_point(cp). {
    return Modifiers.Reroll(comparison: cp)
}
modifier ::= RerollOnce. {
    return Modifiers.Reroll(once: true)
}
modifier ::= RerollOnce compare_point(cp). {
    return Modifiers.Reroll(once: true, comparison: cp)
}

// Criticals

modifier ::= Critical compare_point(cp). {
    return Modifiers.CriticalSuccess(comparison: cp)
}
modifier ::= Fumble compare_point(cp). {
    return Modifiers.CriticalFailure(comparison: cp)
}

// Sorting

modifier ::= SortAscending. {
    return Modifiers.Sorting(ascending: true)
}
modifier ::= SortDescending. {
    return Modifiers.Sorting(ascending: false)
}


// Operations

expr ::= expr(a) Add expr(b). { return .addition(a, b) }
expr ::= expr(a) Subtract expr(b). { return .subtraction(a, b) }
expr ::= expr(a) Multiply expr(b). { return .multiplication(a, b) }
expr ::= expr(a) Divide expr(b). { return .division(a, b) }
expr ::= expr(a) Modulo expr(b). { return .modulus(a, b) }
expr ::= expr(a) Power expr(b). { return .power(a, b) }


// Basic Expressions

expr ::= Integer(a). { return .number(a.token.value) }
expr ::= roll(a). { return .roll(a) }
expr ::= OpenParen expr(a) CloseParen. { return .braced(a) }


// Lists

//expr_list ::= expr(a). { return [a] }
//expr_list ::= expr(a) Comma expr_list(b). { return [a] + b }

modifier_list ::= modifier(a). { return [a] }
modifier_list ::= modifier(a) modifier_list(b). { return [a] + b }


// Compare Points

%nonterminal_type compare_point ComparisonPoint


compare_point ::= Equal Integer(a). {
    return ComparisonPoint(comparison: .equal, value: a.token.value)
}
compare_point ::= NotEqual Integer(a). {
    return ComparisonPoint(comparison: .notEqual, value: a.token.value)
}
compare_point ::= Greater Integer(a). {
    return ComparisonPoint(comparison: .greater, value: a.token.value)
}
compare_point ::= GreaterEqual Integer(a). {
    return ComparisonPoint(comparison: .greaterEqual, value: a.token.value)
}
compare_point ::= Lesser Integer(a). {
    return ComparisonPoint(comparison: .lesser, value: a.token.value)
}
compare_point ::= LesserEqual Integer(a). {
    return ComparisonPoint(comparison: .lesserEqual, value: a.token.value)
}


// Error handling

%capture_errors root.
%capture_errors expr
    end_before(CloseParen).
%capture_errors dice
    end_before(CloseParen).
%capture_errors modifier
    end_before(CloseParen | Add | Subtract | Multiply | Divide | Modulo | Power).
%capture_errors compare_point
    end_before(CloseParen | Add | Subtract | Multiply | Divide | Modulo | Power).
