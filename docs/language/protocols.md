# Protocols

Protocols define behavioral contracts. A type may conform to multiple protocols.

## Syntax and examples

```no-ri
pub protocol Identifiable begin
  def identifier -> string
end

pub protocol Printable begin
  def print
end

# Protocol conformance
pub entity Task < Identifiable begin
  prv let id: string
  def initial(@id) state
  end
  pub def identifier -> string do
    id
  end
end
```

## Semantics

Protocol requirements are public by default. Requirements describe callable behavior without executable do ... end bodies. A conforming type implements each required operation, as Task implements identifier. Types may conform to multiple protocols. The combined inheritance and conformance grammar is a specification in development.

## Rules and constraints

Protocol conformance must not be confused with multiple concrete inheritance. A signature-only requirement is valid in a protocol; a normal executable function needs a body delimiter.

## To be defined

To be defined: Combined concrete-inheritance/conformance grammar, conformance checking, default implementations, associated types, existential representations, generic protocol constraints, and requirement matching.

## Related specifications

[Classes](classes.md) · [Structs](structs.md) · [Generics](generics.md)

[Section navigation](README.md) · [Specification status](../status.md)
