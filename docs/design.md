![](./assets/no-ri-rect-mark.svg)

# Design

The no-ri language emphasises simplicity, expressiveness, readability, safety, performance, and low-level control. The language has a concise syntax and expressive call forms with static types and explicit boundaries for mutation, ownership, and interoperability support for native software as well as integration with other programming language stacks.

## Principles

- **Simplicity.** Concise, consistent syntax should make intent easy to express and type.
- **Readability.** Declarations, block boundaries, and visibility should make programs understandable as they grow.
- **Safety.** Static typing, controlled mutability, optional values, ownership-aware references, explicit errors, and structured concurrency aim to prevent common mistakes. Unsafe operations and foreign calls carry obligations that the programmer must uphold.
- **Performance.** Native compilation, efficient representations, and predictable memory behaviour are design goals. Costs depend on representation, allocation, and ownership choices.
- **Expressiveness.** Value, entity, and variant objects, protocols, generics, closures, and properties support concise abstractions.
- **Control.** Programmers can progress from ARC-managed applications through borrowing and explicit memory management to constrained freestanding programs.

## Language model

no-ri is based on an object oriented abstraction model. However, it does not impose the any particular programming paradigm or "style". Programs written in no-ri can be OOP, procedural/imperative, or even functional in style. In fact, no-ri while not itself a functional language it supports functional programming as a first-class programming style alongside imperative and object-oriented programming. no-ri explicitly specifies first-class functions, callable types, closures with lexical capture, higher-order functions, generics, value-semantic types, and algebraic/sum types amongst other data types and abstraction models.

In no-ri, value objects provide value semantics. Entity objects provide reference semantics and identity while other built-in types participate in the object model. Binding mutability and object mutability are distinct. Properties express access to values, and methods express operations. Variant objects represent constrained sets of cases with optional associated values, computed properties, and pure boolean validation.

An entity declaration can name a concrete prototype using `<`. Static derivation provides state and behaviour at compile time and produces an independent, concrete, final type. The derived entity has its own type identity and cannot be used as a subtype of the prototype. Protocols describe behavioural requirements, and conformance is the only form of object polymorphism.

Modules group declarations and control their visibility. Packages define the boundaries within which modules can be extended. Language behaviour remains consistent across compiler implementations.

Automatic reference counting (ARC) manages reference lifetimes in ordinary native applications. Borrowing and explicit memory management provide progressively more control where needed. A freestanding program must be able to run without a mandatory garbage collector or a general-purpose managed runtime. The C ABI is the primary foreign-function boundary.

## Naming conventions

Objects and named types use CamelCase, as in Task, TaskService, and DivisionError. Methods use lowercase words separated by underscores, as in print_tasks and fetch_data. Predicates may end in ?, and consequential methods may end in !.

Compound filenames use dashes, as in task-manager.md, control-flow.md, and task-test.no-ri. no-ri source files use the .no-ri extension.

Repositories follow the [n-os source convention](tooling/source-organization.md).

## Concise declarations

`initial` reads as defining initial state. Property-bound parameters take their types from stored properties and can reuse defaults where permitted. Initial-state declarations are public by default. Named shorthand reuses local or block names. Functions and closures explicitly declare results with `->`. Without a result declaration, they return no value.

Global functions avoid mandatory object-oriented organisation. `vargs` holds additional positional arguments. Collection spread supplies key/value tuples. Read-only `params` metadata describes signatures separately from call values.

## Related specifications

[Language reference](README.md)
