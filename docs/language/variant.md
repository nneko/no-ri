# Variant Object

Variant objects define a constrained set of cases, including cases carrying associated values. Declare them with `variant object` or its shorthand `variant`.

## Syntax and examples

```no-ri
pub variant Status begin
  pub case pending
  pub case active
  pub case completed
end

pub variant Result<T, E> begin
  pub case success(T)
  pub case failure(E)
end
```

Parenthesized types after a case name declare its associated-value payload. Ordinary variant members default to private. Use `pub case` to expose a case through an accessible variant declaration. Public APIs must expose accessible types.

## Semantics

Variants may provide computed properties and pure boolean validation. A computed property can match `self` to compute a value from the current case. A case name such as `.pending` can omit its variant type when the context identifies it. Variants can conform to protocols. Static derivation with `<` is available for entity declarations and the standalone `object` form.

In a `match` arm, a payload pattern such as `.success(data)` resolves against the subject's variant type. Supply one entry per associated value. Each entry binds an immutable name or uses `_` to ignore the value. The bindings are in scope for the arm's optional `and` condition and its body. A value-producing `match` must be exhaustive.

## Specification in development

The exact validation grammar, purity rules, associated-value construction details, case inference beyond the documented match forms, representation, and equality remain in development.

## Related specifications

[Syntax](syntax.md) · [Control flow](control-flow.md) · [Properties](properties.md) · [Task manager](../examples/task-manager.md)

[Section navigation](README.md) · [Specification status](../status.md)
