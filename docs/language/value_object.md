# Value Object

Value objects provide value semantics, stored properties, and computed properties. Declare them with `value object` or its shorthand `value`.

```no-ri
pub value Point begin
  pub const x: float
  pub const y: float

  initial |@x = 0.0, @y = 0.0| state
  end

  pub computed distance: float do
    (x * x + y * y).sqrt()
  end
end

const origin = Point.initial()
const offset = Point.initial(x: 10.0)
```

## Initial state

Construct a value with `Type.initial(...)`. A synthesized initializer uses declared property defaults and creates no memberwise parameters. A required property without a default needs an explicit initialization path. An explicit initializer uses `state ... end` and can initialize stored properties through property-bound parameters or assignments in its body.

A property-bound parameter takes its type from the property and binds its argument before the body. A mutable property-bound parameter can use the property default as its argument default. An explicit parameter default takes precedence. A declaration-time default consumes a `const` property's single initialization. Reads require definite initialization, and every successful construction path must initialize required state.

Ordinary members default to private, and initializers default to public. Public APIs must expose accessible types.

## Value semantics

Value semantics do not prescribe stack allocation or bitwise copying. Mutating a value member requires a writable path to the enclosing value. Value objects can conform to protocols. Static derivation with `<` is available for entity declarations and the standalone `object` form.

## Specification in development

Layout, copying owned fields, and complete definite-initialization analysis remain in development.

[Syntax](syntax.md) · [Initial state](initial-state.md) · [Properties](properties.md) · [Borrowing](../memory/borrowing.md) · [Language reference](README.md)
