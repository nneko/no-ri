# Variables

Bindings express whether a name can be reassigned. Type inference keeps declarations concise; annotations make intended types explicit.

## Syntax and examples

```nb
const name = "Alice"
var counter = 0
counter += 1

const fixed = 10
fixed = 11  # invalid: immutable binding
```

## Semantics

`const` creates an immutable binding. var creates a mutable binding. Binding mutability and mutability of a referenced object are separate concepts: an immutable name does not by itself establish deep immutability. self identifies the instance in initializer and member examples.

### Constant initialization

A const binding is immutable and may be initialized exactly once. Initialization may occur at declaration or subsequently through assignment.

A declaration without an initializer must specify a type. Until initialized, the binding cannot be read.

Optional types do not imply initialization. An optional constant declared without an initializer remains uninitialized until explicitly assigned a value, including nil.

The compiler enforces definite initialization and prevents multiple initialization of a constant.

## Rules and constraints

Assignments must respect both binding mutability and type compatibility. A public API cannot expose an inaccessible type. Immutable fields are initialised during construction. A bound immutable property cannot be assigned again after its binding.

- const and var declarations without initializers remain uninitialized, even when their types are optional.
- Stored-property initializers execute before the initial body.
- A const stored property initialized at declaration cannot be assigned again inside initial.
- Default initializer parameters provide fallback argument values, not property initialization.
- A synthesized initializer initializes only properties that lack declaration-time initializers.
- All stored properties must be initialized before construction completes.

## To be defined

To be defined: Shadowing, definite initialization analysis, local scope boundaries, capture rules, complete definite-initialisation rules.

## Related specifications

[Types](types.md) · [Classes](classes.md) · [Ownership](../memory/ownership.md)

[Section navigation](README.md) · [Specification status](../status.md)
