# Operators

no-ri provides arithmetic, exponentiation, comparison, boolean, bitwise, assignment, optional-access, and range operators. The language favors clear, expressive syntax, checked arithmetic by default, and explicit operations when low-level control is required.

## Syntax and examples

```no-ri
counter += 1

value * value
x * x + y * y
value % 2 == 0
a / b
age >= 18

not enabled
enabled and ready
enabled or ready

name ?? "Guest"
name?.length
values[1..3]

# Exponentiation
const size = 2 ** 24
const same_size = 2.power_of(24)

# Scientific notation (powers of ten)
const large = 2e24
const small = 1.5e-6

# Numeric grouping
const memory_size = 16_777_216
const mask = 0b1111_0000

# Bitwise operations
const masked = flags & mask
const combined = flags | mask
const toggled = flags ^ mask
const inverted = ~mask
const shifted_left = value << 2
const shifted_right = value >> 2

# Wrapping arithmetic
const maximum: u8 = 255
const one: u8 = 1
const wrapped = maximum &+ one  # 0
```

## Semantics

### Boolean operators

no-ri supports three logical boolean operators:

| Operator | Meaning     |
| -------- | ----------- |
| `and`    | Logical AND |
| `or`     | Logical OR  |
| `not`    | Logical NOT |

Boolean operators require `boolean` operands. General truthiness is not assumed.

`and` and `or` use short-circuit (lazy) evaluation:

- `a and b` evaluates `b` only when `a` is true.
- `a or b` evaluates `b` only when `a` is false.
- `not a` evaluates `a` once and negates its boolean value.

There are no symbolic equivalents for logical boolean operations. In particular, `&&`, logical `||`, and prefix logical `!` are not supported.

### Arithmetic operators

| Operator  | Meaning          |
| --------- | ---------------- |
| `+`       | Addition         |
| `-`       | Subtraction      |
| `*`       | Multiplication   |
| `/`       | Division         |
| `%`       | Remainder        |
| `**`      | Exponentiation   |
| Unary `-` | Numeric negation |

Numeric overflow is checked by default for fixed-width integer arithmetic. Integer division follows integer semantics.

The `number` type supports arbitrary-precision numeric values and is not subject to fixed-width integer overflow.

### Exponentiation

The `**` operator raises a value to a power.

```no-ri
const squared = 7 ** 2
const cubed = 3 ** 3
const size = 2 ** 24
```

Exponentiation is also available through the `power_of` method:

```no-ri
const size = 2.power_of(24)
```

`power_of` and `**` express the same mathematical operation.

Exponentiation is right-associative:

```no-ri
2 ** 3 ** 2  # 512: 2 ** (3 ** 2)
```

Exponentiation binds more tightly than unary negation on its left:

```no-ri
-2 ** 2      # -4
(-2) ** 2    # 4
```

A unary exponent is permitted syntactically:

```no-ri
2 ** -3
```

The result must satisfy the applicable numeric type rules. Negative exponents do not implicitly guarantee a fractional result for an integer type.

Fixed-width integer exponentiation uses checked arithmetic. There is no wrapping exponentiation operator.

### Scientific notation

Scientific notation uses lowercase `e` to represent multiplication by a power of ten.

```no-ri
const large = 2e24
const small = 1.5e-6
const positive = 3e+8
```

For example:

- `2e24` represents 2 × 10²⁴.
- `2 ** 24` represents 2 raised to the power 24.

Scientific notation is part of numeric literal syntax, not an exponentiation operator.

Only lowercase `e` is supported. Uppercase `E` is invalid as an exponent marker.

The numeric type of a scientific-notation literal follows no-ri's numeric literal typing rules, including contextual typing for `number`, `float`, and `decimal` where applicable.

### Numeric separators

Underscores may be used to group digits within numeric literals for readability.

```no-ri
const population = 1_500_000
const memory_size = 16_777_216
const fraction = 3.141_592_653
const permissions = 0b1111_0000
const address = 0xFFFF_0000
const scientific = 1_000e3
```

Underscores do not affect the numeric value or type.

Rules:

- An underscore must occur between valid digits of the same numeric component.
- Consecutive underscores are invalid.
- Leading or trailing underscores are invalid.
- Underscores cannot be adjacent to a decimal point.
- Underscores cannot be adjacent to an exponent marker or exponent sign.
- Grouping is optional and has no effect on numeric evaluation.

Examples of invalid numeric literals:

```no-ri
1__000
1_.5
1e_6
1_000_
```

### Bitwise operators

no-ri adopts Swift's six core bitwise operators and their corresponding semantics.

| Operator | Meaning     |
| -------- | ----------- | ---------- |
| `~`      | Bitwise NOT |
| `&`      | Bitwise AND |
| `        | `           | Bitwise OR |
| `^`      | Bitwise XOR |
| `<<`     | Left shift  |
| `>>`     | Right shift |

Bitwise operations apply to compatible integer types and operate on their binary representations.

```no-ri
const a: u8 = 0b1100
const b: u8 = 0b1010

const intersection = a & b  # 0b1000
const union = a | b         # 0b1110
const difference = a ^ b    # 0b0110
```

Bitwise operators evaluate their operands normally and do not use boolean short-circuit evaluation.

Bitwise NOT complements the bits within the operand's width.

Shift operations follow Swift's fixed-width integer semantics:

- Left shift moves bits toward the most significant position, discarding bits shifted beyond the width and filling vacated low-order positions with zero.
- Unsigned right shift fills vacated high-order positions with zero.
- Signed right shift performs an arithmetic shift, preserving the sign.
- Shift counts greater than or equal to the operand's bit width are permitted, following Swift's defined shift behavior rather than causing an overflow error.
- Negative shift counts reverse the shift direction, following Swift's shift semantics.

Bitwise operators do not implicitly convert integer operands into boolean values.

#### NAND and NOR

NAND and NOR use compositions of existing bitwise operators rather than dedicated operators.

```no-ri
const nand_result = ~(a & b)
const nor_result = ~(a | b)
```

XOR uses `^` directly:

```no-ri
const xor_result = a ^ b
```

No separate `nand`, `nor`, or `xor` operator keywords are introduced.

### Wrapping arithmetic

no-ri supports Swift-style explicit wrapping arithmetic.

| Operator | Meaning                 |
| -------- | ----------------------- |
| `&+`     | Wrapping addition       |
| `&-`     | Wrapping subtraction    |
| `&*`     | Wrapping multiplication |

Wrapping arithmetic is supported only for fixed-width integer types:

- Signed integers: `i8`, `i16`, `i32`, `i64`, `i128`
- Unsigned integers: `u8`, `u16`, `u32`, `u64`, `u128`
- Platform-sized unsigned integer: `usize`

Wrapping arithmetic is not supported for arbitrary-precision `number`.

For an N-bit integer, wrapping arithmetic operates modulo 2^N. Signed results are interpreted using the corresponding fixed-width signed representation.

```no-ri
const maximum: u8 = 255
const one: u8 = 1
const zero: u8 = 0

const a = maximum &+ one  # 0
const b = zero &- one     # 255
const c = maximum &* one  # 255
```

Ordinary fixed-width arithmetic remains checked:

```no-ri
const maximum: u8 = 255
const one: u8 = 1

const invalid = maximum + one  # Overflow
const valid = maximum &+ one   # 0
```

Wrapping is always explicit. It is never implicitly selected to avoid an overflow error.

There is no wrapping exponentiation operator.

### Comparison operators

| Operator | Meaning               |
| -------- | --------------------- |
| `==`     | Equality              |
| `!=`     | Inequality            |
| `<`      | Less than             |
| `<=`     | Less than or equal    |
| `>`      | Greater than          |
| `>=`     | Greater than or equal |

Comparison operations produce `boolean` results.

Identity is expressed using `same`, rather than inferred from equality.

### Assignment operators

Assignment uses `=`.

Compound assignments include:

| Operator | Meaning                   |
| -------- | ------------------------- | --------------------- |
| `+=`     | Addition assignment       |
| `-=`     | Subtraction assignment    |
| `*=`     | Multiplication assignment |
| `/=`     | Division assignment       |
| `%=`     | Remainder assignment      |
| `&=`     | Bitwise AND assignment    |
| `        | =`                        | Bitwise OR assignment |
| `^=`     | Bitwise XOR assignment    |
| `<<=`    | Left-shift assignment     |
| `>>=`    | Right-shift assignment    |

Compound assignments preserve the applicable arithmetic, bitwise, type-safety, and mutability rules.

Wrapping compound assignments such as `&+=`, `&-=`, and `&*=` are supported:

### Compound assignment operators

no-ri supports compound assignment operators for arithmetic, bitwise, shift, and wrapping arithmetic operations.

A compound assignment applies an operation to the current value of a mutable destination and assigns the result back to that destination.

| Operation               | Operator | Compound assignment |
| ----------------------- | -------- | ------------------- |
| Addition                | `+`      | `+=`                |
| Subtraction             | `-`      | `-=`                |
| Multiplication          | `*`      | `*=`                |
| Division                | `/`      | `/=`                |
| Remainder               | `%`      | `%=`                |
| Bitwise AND             | `&`      | `&=`                |
| Bitwise OR              | `\|`     | `\|=`               |
| Bitwise XOR             | `^`      | `^=`                |
| Left shift              | `<<`     | `<<=`               |
| Right shift             | `>>`     | `>>=`               |
| Wrapping addition       | `&+`     | `&+=`               |
| Wrapping subtraction    | `&-`     | `&-=`               |
| Wrapping multiplication | `&*`     | `&*=`               |

#### Semantics

Compound assignments are equivalent in effect to applying the underlying operator and assigning the result.

```no-ri
counter += 1
flags |= mask
value <<= 2
counter &+= 1
```

Equivalent to:

```no-ri
counter = counter + 1
flags = flags | mask
value = value << 2
counter = counter &+ 1
```

The assignment destination is evaluated exactly once, including any indexing, property access, or other expressions required to identify it.

Compound assignments require a mutable destination and obey the operand-type constraints of their underlying operators.

Ordinary arithmetic compound assignments retain checked overflow behavior.

Wrapping compound assignments (`&+=`, `&-=`, `&*=`) are restricted to fixed-width integer types (`i8`–`i128`, `u8`–`u128`, and `usize`) and perform arithmetic modulo 2^N, where N is the integer's bit width.

#### Precedence and associativity

All compound assignment operators have the same precedence and right-associativity as ordinary assignment (`=`).

The scanner uses longest-match tokenization to recognize compound operators such as `&+=`, `&-=`, `&*=`, `<<=`, and `>>=` as individual operators.

### Optional access and coalescing

Safe optional access uses `?.`.

```no-ri
name?.length
```

Nil coalescing uses `??`.

```no-ri
const display_name = name ?? "Guest"
```

Coalescing evaluates its fallback lazily, only when the left operand is nil.

### Range operators

The range operator `..` constructs a range.

```no-ri
values[1..3]
```

Precise endpoint inclusion and additional range forms remain to be defined.

## Operator precedence and associativity

Operators are ordered from highest to lowest precedence.

| Precedence | Operators | Associativity |
| --- | --- | --- | --- |
| 1 | Member access, optional access, invocation | Left |
| 2 | `**` | Right |
| 3 | Unary `not`, `~`, `-` | Unary |
| 4 | `*`, `/`, `%`, `&*` | Left |
| 5 | `+`, `-`, `&+`, `&-` | Left |
| 6 | `<<`, `>>` | Left |
| 7 | `&` | Left |
| 8 | `^` | Left |
| 9 | ` | ` | Left |
| 10 | Comparisons, equality, identity | Non-associative unless otherwise specified |
| 11 | `and` | Left |
| 12 | `or` | Left |
| 13 | Assignment and compound assignment | Right |

Exponentiation has special unary binding behavior:

```no-ri
-2 ** 2    # -(2 ** 2)
2 ** -3    # 2 ** (-3)
```

Parentheses may always be used for explicit grouping.

```no-ri
const result = (a | b) & mask

if (flags & required_mask) == required_mask and not disabled
  activate()
end
```

The table establishes the relative precedence of the listed operators. Final placement of coalescing, ranges, and any additional operators remains to be defined.

## Rules and constraints

### Operator and declaration syntax

The `|` symbol serves two distinct grammatical purposes:

- Bitwise OR within expressions.
- Parameter delimiters within callable declarations.

```no-ri
combine |a: u8, b: u8| -> u8 do
  a | b
end
```

The empty parameter declaration uses `||`:

```no-ri
greet || do
  print("Hello")
end
```

`||` is not a boolean operator.

An explicit `def` remains optional for all declarations. The following is equivalent:

```no-ri
def greet do
  print("Hello")
end
```

Parentheses `(...)` supply invocation arguments, while pipe delimiters `|...|` declare callable parameters.

Trailing closures use `do` before their parameter delimiters:

```no-ri
numbers.each do |number|
  print(number)
end
```

### Identifier suffixes

The `!` suffix in a method name such as `reset!` is part of the identifier, not a logical negation operator.

The `?` suffix in predicate identifiers is distinct from optional access `?.` and coalescing `??`.

### Generic syntax and shifts

The parser distinguishes generic type delimiters from shift operators.

```no-ri
const values: list<list<integer>>
const shifted = value >> 2
```

Nested generic closing brackets must not require whitespace solely to distinguish them from `>>`.

### Evaluation order

Boolean `and` and `or` use lazy short-circuit evaluation.

Nil coalescing `??` evaluates its fallback lazily.

Arithmetic, comparison, bitwise, and exponentiation operations follow no-ri's ordinary expression evaluation rules. Bitwise operators do not short-circuit.

### Numeric safety

- Ordinary fixed-width integer arithmetic is checked for overflow.
- Wrapping arithmetic must use `&+`, `&-`, or `&*` explicitly.
- Wrapping arithmetic is restricted to fixed-width integer types.
- Arbitrary-precision `number` does not support wrapping arithmetic.
- Exponentiation does not support wrapping.
- Scientific notation uses lowercase `e` exclusively.
- Numeric underscores affect presentation only, never value or type.

## To be defined

The following details remain open:

- Complete operator inventory and any additional compound assignments.
- Exact precedence of nil coalescing and range operators relative to other expressions.
- Range endpoint inclusion and additional range forms.
- Operator overloading rules and constraints.
- Mixed numeric-type operations and promotion rules.
- Exact exponentiation result typing, particularly for negative exponents and integer operands.
- Division-by-zero and remainder failure behavior across numeric types.
- Detailed treatment of fixed-width versus non-fixed-width integer types for bitwise operations.
- Precise evaluation-order guarantees for ordinary binary operators where not already specified.

## Related specifications

[Types](types.md) · [Control flow](control-flow.md) · [Collections](collections.md) · [Functions](functions.md) · [Arguments](arguments.md)

[Section navigation](README.md) · [Specification status](../status.md)
