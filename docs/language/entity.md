# Entity

Entities provide reference semantics, identity, and encapsulated state. Declare an entity with `entity object`, `entity`, or the standalone `object` form.

## Initial state

```no-ri
pub entity User begin
  prv const name_value: string

  initial |@name_value| state
  end

  pub computed name: string do
    name_value
  end
end

const user = User.initial(name_value: "Alice")
```

Construct an entity with `Type.initial(...)`. An initializer uses `state ... end` and defaults to public. A property-bound parameter takes its type from the stored property and binds its argument before the body. A mutable property-bound parameter can use the property default as its argument default. An explicit parameter default takes precedence. A declaration-time default consumes a `const` property's single initialization. Required state must be initialized on every successful construction path.

Ordinary members default to private. Use `pub`, `res`, and `prv` for explicit access control. Public APIs must expose accessible types.

## Static derivation

The optional `< Prototype` clause names one concrete entity. The compiler incorporates all prototype members and protocol conformances into an independent, concrete, final entity type. A derived entity can itself serve as the prototype for another derivation. Derivation creates no subtype relationship or implicit conversion to the prototype type. Protocol conformance is the only form of object polymorphism.

The compiler checks the resulting declarations and conformances for conflicts at compile time. The programmer must resolve any conflict before compilation can succeed.

## Prototype initialization

`parent.initial(...)` applies a prototype initializer to the prototype-derived state of the instance being constructed. The resulting instance has the derived entity's type.

Automatic prototype initialization runs after declaration-time defaults and any property-bound parameter bindings for the derived entity. With no declared initializer, construction calls `parent.initial()` with no explicit arguments. With a declared initializer, the automatic call forwards matching parameters by name. Omitted prototype parameters can use defaults. A missing or ambiguous applicable initializer is a compile-time error.

An explicit `parent.initial(...)` call suppresses automatic forwarding for that initializer. A declared initializer with a signature identical to a prototype initializer's must make the call explicitly. Every successful construction path must initialize prototype-derived state.

## Reference semantics

Ordinary native applications use automatic reference counting (ARC) to manage entity-reference lifetimes. Object identity is distinct from value equality and can be queried with `same`. An immutable binding can refer to an entity with mutable state.

## Specification in development

Destruction, equality, and managed lifetime implementation remain in development.

[Syntax](syntax.md) · [Initial state](initial-state.md) · [Protocols](protocols.md) · [Properties](properties.md) · [Allocation](../memory/allocation.md) · [Language reference](README.md)
