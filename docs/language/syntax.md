# Syntax

no-ri source files use the .no-ri or .no-ri extension. Declarations use readable keywords and explicit block delimiters. Every source file belongs to an implicit or explicit module.

## Syntax and examples

```no-ri
# A comment
const name: string = "Alice"
var count = 0

def greet(name: string) -> string do
  "Hello, \(name)"
end

numbers.each |number| do
  print(number)
end
numbers.map({ |number| number * 2 } -> integer)
names.map({ |name| name.upcase() } -> string)
```

## Semantics

Type annotations follow a colon. Return annotations follow ->. Executable function bodies require do ... end; modules, classes, structs, enums, and control-flow forms use their shown declaration-specific block syntax. Blocks may use do ... end or the short brace form. Identifiers may carry a predicate ? suffix or consequential ! suffix.

> An unparenthesized call may accept expressions as arguments, but any function call occurring within those expressions must use parenthesized call syntax.

Examples

| Expression             | Interpretation              | Valid |
| ---------------------- | --------------------------- | ----- |
| print "Hello"          | print("Hello")              | Yes   |
| add 10, 20             | add(10, 20)                 | Yes   |
| print add, 10, 20      | print(add, 10, 20)          | Yes   |
| print add(10, 20)      | print(add(10, 20))          | Yes   |
| print 10 + 20          | print(10 + 20)              | Yes   |
| print add(10, 20) \* 2 | print(add(10, 20) \* 2)     | Yes   |
| print add 10, 20       | Ambiguous nested call       | No    |
| print(add 10, 20)      | Unparenthesized nested call | No    |

## Rules and constraints

A declaration signature in a protocol is not an executable function body. The ! suffix is a naming convention, distinct from prefix logical negation.

## To be defined

To be defined: Formal lexical grammar, identifier character classes, reserved-word set, escapes, separators, line continuation, expression grammar, and ambiguity resolution. The formal grammar is a specification in development.

## Related specifications

[Functions](functions.md) · [Operators](operators.md) · [Modules](modules.md)

[Section navigation](README.md) · [Specification status](../status.md)

## Initial state and results

Initial state uses def initial(...) state ... end and defaults to public. Functions and closures require -> Type to return a value; otherwise final expression values are discarded. Brace closures place -> Type after the closing brace. See [initial state](initial-state.md) and [closures](closures.md).
