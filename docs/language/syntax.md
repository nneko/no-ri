# Syntax

no-ri source files use the `.no-ri` extension and belong to a module. A file without an explicit module declaration has an implicit module named after the file, without the extension. A file one directory level deep inherits the containing directory’s package name. A file nested more deeply must state its package affiliation explicitly. See [Modules and packages](#modules-and-packages).

Declaration containers use `begin ... end`. Executable definitions use `do ... end`. Initializer bodies use `state ... end`. Callable declarations use `|parameters|` or `||`. Calls use `(...)` or the command-style form defined below.

```no-ri
# Accounts.no-ri
package Ledger includes(["Account", "sample_account"])
```

Package inclusion selects modules, functions, constants, and variables. An object type belongs to its enclosing module, so include the module to give the type that package affiliation. The following file explicitly names its module and includes it in `Ledger`.

```no-ri
# billing.no-ri
package Ledger includes(["Accounts"])

module Accounts begin
  pub entity object Account begin
    const owner: string
    balance_value: decimal = 0

    initial |@owner| state
    end

    pub computed balance: decimal do
      get do
        balance_value
      end

      res set |amount| do
        balance_value = amount
      end
    end

    pub deposit |amount: decimal| do
      balance_value += amount
    end

    pub description || -> string do
      "\(owner): \(balance)"
    end
  end

  sample_account || -> Account do
    Account.initial(owner: "Alice")
  end

  prv sample_owner || -> string do
    "Alice"
  end
end
```

`Account` is public. Its stored properties are private by default, and its initializer is public by default. `balance` has a public getter and a restricted setter. `sample_account` uses the restricted module-member default. `prv` confines `sample_owner` to the original module declaration block.

## Grammar notation

The productions use EBNF. Quoted text denotes literal source tokens. Brackets denote an optional element, braces denote repetition, and `|` separates alternatives. `NL` denotes a significant newline after applying continuation rules. `EOF` denotes end of file.

A statement list can be empty. Significant newlines separate consecutive statements. A list’s closing token or branch boundary can terminate its last statement. Declaration lists use the same separation rules and admit only declarations allowed by the enclosing construct. Grammar acceptance is subject to name resolution, type checking, access control, and definite initialization.

## Lexical grammar

### Source characters and identifiers

Source files are UTF-8. Identifiers are case-sensitive and compare by their spelling as written. They start with `_` or a Unicode `XID_Start` character. Subsequent characters may be `_` or Unicode `XID_Continue` characters. An identifier may have a single terminal `?` or `!`.

```ebnf
identifier-start = "_" | Unicode-XID-Start ;
identifier-continue = "_" | Unicode-XID-Continue ;
identifier-core = identifier-start, { identifier-continue } ;
identifier = identifier-core, [ "?" | "!" ] ;
```

A predicate callable ends in `?` and returns `boolean`. The `!` suffix marks consequential behavior by convention. The scanner gives `?.` and `??` priority over a terminal `?`, and `!=` priority over a terminal `!`. In type position a terminal `?` marks an optional type, as in `string?`.

### Reserved and contextual words

Reserved words are recognized as complete, case-sensitive spellings. For example, `list` is reserved and `list_items` is an identifier.

| Role | Reserved words |
| --- | --- |
| Declarations and modifiers | `async`, `computed`, `const`, `def`, `entity`, `extend`, `import`, `initial`, `module`, `object`, `package`, `protocol`, `prv`, `pub`, `res`, `value`, `var`, `variant` |
| Blocks and control flow | `begin`, `break`, `case`, `continue`, `default`, `do`, `elif`, `else`, `end`, `for`, `if`, `in`, `match`, `return`, `state`, `while` |
| Errors and concurrency | `await`, `concurrent`, `defer`, `enforce`, `handle`, `raise`, `raises`, `spawn`, `try` |
| Literals and word operators | `and`, `between`, `false`, `nil`, `not`, `or`, `same`, `true` |
| Collection types | `array`, `collection`, `list`, `map`, `sequence`, `set`, `slice`, `tuple` |
| Symbol and no-result types | `symbol`, `void` |

| Context                        | Contextual words                  |
| ------------------------------ | --------------------------------- |
| Imports                        | `from`, `as`                      |
| Package inclusion              | `includes`                        |
| Protocol conformance           | `conforms`, `to`                  |
| Explicit getter headers        | `get`                             |
| Instance and parent references | `self`, `parent`                  |
| Ownership and reference forms  | `borrow`, `mut`, `take`, `unsafe` |

`initial` is also a selector in construction and parent initialization. `set` introduces an explicit setter or the collection constructor `set(...)`, depending on context. `get` is available as an ordinary identifier outside getter headers. Built-in names such as `integer`, `boolean`, `string`, and `ref` resolve through the applicable namespace. `vargs` is an implicit local in variadic callables and an ordinary identifier elsewhere.

### Punctuation and token selection

Use the longest applicable token at the current position. Multi-character tokens are contiguous. Comments and whitespace separate tokens.

```text
Delimiters and separators   ( ) [ ] { } , : :: . @ -> =>
Callable and optional      | || ? ?. ??
Arithmetic                 + - * / % ** &+ &- &*
Bitwise                    ~ & | ^ << >>
Comparison                 == != < <= > >=
Assignment                 = += -= *= /= %= &= |= ^= <<= >>= &+= &-= &*=
Ranges and spread          .. ..< >.. ...
Comment markers            # ###
Explicit continuation      \ immediately followed by a physical line break
```

`|` delimits callable parameters or callable input types, joins pattern alternatives, or denotes bitwise OR in an expression. `||` marks an empty parameter or input type list. `()` invokes a callable with no explicit arguments. A parser consuming nested generic closers can split `>>` into two `>` tokens. In an ordinary expression `>>` is a shift operator. `..<`, `>..`, and `...` are distinct tokens.

### Numeric literals

```ebnf
digit = "0" … "9" ;
binary-digit = "0" | "1" ;
hex-digit = digit | "a" … "f" | "A" … "F" ;

decimal-digits = digit, { [ "_" ], digit } ;
binary-digits = binary-digit, { [ "_" ], binary-digit } ;
hex-digits = hex-digit, { [ "_" ], hex-digit } ;

integer-literal =
    decimal-digits
  | "0b", binary-digits
  | "0x", hex-digits ;

exponent = "e", [ "+" | "-" ], decimal-digits ;

decimal-literal =
    decimal-digits, ".", decimal-digits, [ exponent ]
  | decimal-digits, exponent ;

numeric-literal = integer-literal | decimal-literal ;
```

An underscore separates two digits of the same component and has no effect on value or type. Scientific notation uses lowercase `e`. A sign immediately after `e` belongs to the exponent. A leading sign belongs to the expression grammar. A decimal point belongs to the literal only when a decimal digit follows it. Thus `2.power_of(24)` selects a member and `1..3` forms a range.

```no-ri
const population = 1_000_000
const mask = 0b1111_0000
const color = 0xFF_00_AA
const fraction = 3.141_592
const small = 1.5e-6
const large = 3e+8
const power = 2 ** 24
```

`1__000`, `1_.5`, `1e_6`, `1_000_`, and `2E24` are invalid numeric spellings.

### Strings and interpolation

Double-quoted strings contain text, escapes, and interpolated expressions. String values use graphemes as their text units. The scanner recognizes delimiters and escapes from the source spelling.

```ebnf
string = single-line-string | multiline-string ;
single-line-string = '"', { string-character | escape | interpolation }, '"' ;
escape = '\"' | '\\' | '\n' | '\r' | '\t' | unicode-escape ;
unicode-escape = '\u{', hex-digit, { hex-digit }, '}' ;
interpolation = '\(', expression, ")" ;
```

A `string-character` excludes the double quote, backslash, and physical line break. A Unicode escape contains one to eight hexadecimal digits and must denote a Unicode scalar. Unknown escapes, invalid scalars, and unterminated strings are errors. Inside interpolation the scanner resumes ordinary code tokenization and balances parentheses. Nested strings follow the string rules.

A multiline string starts with `"""` followed by a physical line break. Its closing `"""` starts a line after optional indentation. The newline immediately after the opening delimiter and the newline immediately before the closing delimiter are excluded from the value. The indentation before the closing delimiter is stripped from each content line. Nonblank content lines must begin with that indentation. Blank lines containing less indentation contribute an empty line. Physical line breaks in the content become LF. Escapes and interpolation work in both string forms.

```no-ri
const greeting = "Hello, \(name.upcase())"
const accent = "\u{00E9}"

const message = """
  Hello, \(name).
  Your order is ready.
  """
```

### Symbols

A symbol literal is `:` immediately followed by an identifier-shaped spelling. A terminal `?` or `!` can be part of the symbol name.

```ebnf
symbol-literal = ":", identifier-core, [ "?" | "!" ] ;
```

The parser recognizes symbol literals where expressions can begin. A colon in a type annotation, argument label, or keyed entry retains its separator role. `::` takes lexical priority over `:`. Symbols can serve as keys or values where the collection type permits them. A leading dot introduces a context-qualified variant case, as in `.pending`.

```no-ri
const predicate: symbol = :ready?
record(status: :active)
const priorities: map<symbol, integer> = {:pending => 1, :active => 2}
```

### Comments

`#` starts a line comment in ordinary code and extends through the rest of the physical line. The newline remains available for statement termination.

A multiline comment opens and closes with a standalone `###` fence. A fence line contains exactly three consecutive `#` characters with optional spaces or tabs before and after them. The scanner checks for a fence before recognizing a line comment. The next fence closes the comment. Multiline comments do not nest. End of file before the closing fence is an error. The scanner retains physical line breaks for the newline rules. Comment markers in string text are literal characters. Ordinary code rules resume inside interpolation.

```no-ri
const count = 10  # Inline comment

###
Multiline comment.
###

report || do
  ###
  Fences can be indented.
  ###
  print(count)
end

### This line is a line comment.
```

## Whitespace, separators, and line continuation

Spaces and horizontal tabs separate tokens. Indentation is for readability, except where the multiline string grammar uses it. LF, CRLF, and CR are physical line breaks. Blank lines and comment-only lines create no statements. Semicolons are invalid outside strings and comments.

Apply continuation in this order.

1. In ordinary code, a backslash immediately followed by a physical line break replaces the pair with token-separating whitespace. It suppresses exactly one line break. A trailing space or comment prevents continuation. A backslash elsewhere in ordinary code is invalid.
2. Inside grouping, argument, indexing, collection, generic, and parameter delimiters, line breaks separate tokens. Commas separate list entries. An executable body nested inside a list applies statement termination to its own statements.
3. Continue when a consumed token requires another operand or component. Examples include infix, range, and assignment operators, commas, `->`, and member selectors. A colon continues where its production requires a type or value. Named-argument shorthand `name:` can end at an argument boundary.
4. A following line can continue a member chain with `.` or `?.`. Outside a continuing expression, a leading `+`, `-`, `(`, or `[` does not attach to a completed statement.
5. A recognized declaration header can continue into its applicable `raises`, `do`, `begin`, or `state` clause. Command-style arguments begin on the callee’s logical line. A trailing closure opener follows the callee or its arguments on the same logical line.
6. Other newlines terminate complete statements. End of file and an enclosing closing token or branch boundary also terminate a complete statement.

A trailing comma is permitted where the applicable production allows it. Backslashes in comments have no effect. Backslashes in strings follow the string grammar.

```no-ri
const total = subtotal \
  + tax

const result = service
  .fetch()
  .decode()

const combined = (
  first
  + second
)
```

## Declarations and modifiers

The prefix order is `[def] [visibility] [async]` where applicable. `def` is optional and has no effect on visibility, type, or runtime behavior. The declaration kind determines where visibility and `async` apply.

```ebnf
visibility = "pub" | "res" | "prv" ;
decl-prefix = [ "def" ], [ visibility ] ;
named-head = identifier, [ generic-parameters ] ;
return-annotation = "->", result-type ;
error-contract = "raises", type ;

callable-declaration =
    "def", [ visibility ], [ "async" ], named-head, [ callable-parameters ],
    [ return-annotation ], [ error-contract ], executable-body
  | [ visibility ], [ "async" ], named-head, callable-parameters,
    [ return-annotation ], [ error-contract ], executable-body ;

executable-body = "do", statement-list, "end" ;
```

`greet || do ... end`, `def greet || do ... end`, and `def greet do ... end` declare the same parameterless callable. `greet do ... end` calls `greet` with a trailing closure. A `raises` clause follows the optional return annotation and names one error type.

### Access control

An omitted modifier uses the default for the declaration kind and its enclosing context. `def` and visibility are independent.

| Declaration or member | Default access |
| --- | --- |
| Module declaration | Public |
| Ordinary module member | Restricted |
| Ordinary entity, value object, variant, or standalone object member | Private |
| Initializer | Public |
| Protocol requirement | Public |
| Explicit computed-property accessor | Inherits the property’s access |

| Modifier | Access |
| --- | --- |
| `pub` | Exposes the declaration through its enclosing public interface. The enclosing declaration must be accessible. |
| `res` | Grants access through authorized relationships, including authorized extensions of a module within the same package. |
| `prv` | Confines access to the owning boundary. A private module member is available only within its original declaration block. |

A public API must expose accessible types. The initializer default applies where the object kind permits an initializer.

```no-ri
module Billing begin
  currency: string = "JMD"
  prv const internal_prefix = "bill"

  pub value Invoice begin
    const amount: decimal

    initial |@amount| state
    end

    pub computed total: decimal do
      amount
    end
  end
end

extend module Billing begin
  pub default_currency || -> string do
    currency
  end
end
```

### Mutable and immutable bindings

`const` declares an immutable binding. `var` declares a mutable binding. A mutable declaration may omit `var` where the context admits a declaration unambiguously and both a type and an initializer are present.

```ebnf
binding =
    ("const" | "var"), identifier,
    ( ":", type, [ "=", expression ] | "=", expression )
  | identifier, ":", type, "=", expression ;

binding-declaration = decl-prefix, binding ;
```

| Form                     | Meaning                                       |
| ------------------------ | --------------------------------------------- |
| `name: string = "no-ri"` | Mutable declaration with an explicit type.    |
| `var name = "no-ri"`     | Mutable declaration with an inferred type.    |
| `var name: string`       | Mutable declaration for later initialization. |
| `const name = "no-ri"`   | Immutable declaration with an inferred type.  |
| `name = "no-ri"`         | Assignment to an existing binding.            |

A declaration establishes the binding’s type. Assignment requires an existing destination with an established type. A declaration without an initializer must state its type. Optional bindings may be uninitialized, and an explicit `nil` initializes them. Immutable bindings can be initialized once. The compiler checks definite initialization before reads.

## Parameters, arguments, and calls

```ebnf
callable-parameters = "||" | "|", parameter-list, "|" ;

parameter-list =
    "..."
  | parameter, { ",", parameter }, [ ",", "..." ] ;

parameter = identifier, [ ":", type ], [ "=", parameter-default ] ;
parameter-default = expression ;

argument-list = "(", [ argument, { ",", argument } ], ")" ;
argument = identifier, ":", [ expression ] | expression, [ "..." ] ;

member-selector = identifier | "initial" ;
member-access = receiver, ".", member-selector ;
optional-access = receiver, "?.", member-selector ;
index-access = receiver, "[", expression, "]" ;

explicit-call =
    callee, [ generic-arguments ], argument-list
  | "set", argument-list ;
```

A property read uses `.name`. Invocation uses `.name(...)`. Member selection, indexing, and invocation can chain. Parameter annotations can be omitted where the type rules determine the type, including contextual closure parameters and property-bound initializer parameters.

A default is evaluated afresh when its argument is omitted. It resolves names in the declaration scope and cannot refer to another parameter of the same callable. Positional binding reserves arguments for required parameters, including required parameters after defaulted parameters. Named arguments identify parameters directly. `name:` is shorthand for `name: name`, resolved in local or block scope.

A final `...` parameter captures extra positional arguments in `vargs`. Postfix `expression...` spreads arguments. A keyed collection supplies positional key-value tuples when spread.

At the outer level of a pipe-delimited parameter list, `|` closes the list. Enclose bitwise OR in a default expression within nested expression delimiters.

```no-ri
inspect |flags: u8 = (read_mask | write_mask), ...| do
  print(flags, vargs)
end
```

### Calls without parentheses

A command-style call has a callee followed by whitespace and at least one argument on the same logical line. An opening `(` immediately after the callee starts an explicit argument list. Parse arguments with command-style calls disabled inside them. A comma continues the argument list. If the complete sequence also parses as an ordinary operator expression, the operator expression takes precedence.

| Form | Interpretation |
| --- | --- |
| `print "Hello"` | `print("Hello")` |
| `add 10, 20` | `add(10, 20)` |
| `print add, 10, 20` | Three arguments, beginning with the value named `add`. |
| `print 10 + 20` | One argument containing an addition. |
| `print add(10, 20) * 2` | One argument containing a nested call and multiplication. |
| `print add 10, 20` | Invalid nested command-style call. |
| `print(add 10, 20)` | Invalid nested command-style call. |
| `reset()` | Call with zero arguments. |
| `reset do ... end` | Call with a trailing closure. |

### Return annotations

A callable with a value result must supply a compatible value on each normally completing path. Its final expression can supply that value. An explicit `return expression` can supply it earlier. A bare `return` exits a no-result callable. A callable without a return annotation, or with `-> void`, discards its final expression value.

## Closures

A brace closure starts with `|parameters|` or `||`. This distinguishes it from a keyed collection literal. Its optional return annotation follows `}`. A long closure starts with `do` or `async do`, followed by an optional pipe list. A long closure’s return annotation follows its pipe list. Use `||` when a parameterless long closure declares a result.

```ebnf
brace-closure =
    "{", callable-parameters, statement-list, "}", [ return-annotation ] ;

long-closure-head = callable-parameters, [ return-annotation ] ;

long-closure =
    [ "async" ], "do", [ long-closure-head ], statement-list, "end" ;

trailing-call =
    (callee | explicit-call | command-style-call), long-closure
  | (callee | explicit-call), brace-closure ;
```

A long closure can stand alone in an expression or follow a call as its trailing argument. Closure parameters support contextual types, defaults, and variadic capture under the shared argument rules. Names resolve lexically. Closure results follow the callable return rules. Calls with trailing `do` closures in control-flow headers follow the parenthesization rule in [Control flow and errors](#control-flow-and-errors).

```no-ri
const double = { |item: integer| item * 2 } -> integer
const next = { || 42 } -> integer

const square = do |item: integer| -> integer
  item * item
end

const fetch = async do |url: string| -> string
  await request(url)
end

numbers.each do |item|
  print(item)
end

const doubled = numbers.map do |item| -> integer
  item * 2
end
```

## Types, collections, and generics

Type annotations follow `:`. A postfix `?` forms an optional type. Parentheses group a type when necessary.

```ebnf
collection-type-word =
    "array" | "collection" | "list" | "map"
  | "sequence" | "set" | "slice" | "tuple" ;

qualified-name = identifier, { "::", identifier } ;
type-head = qualified-name | collection-type-word | "symbol" ;
named-type = type-head, [ generic-arguments ] ;
type = callable-type | (named-type | "(", type, ")"), [ "?" ] ;
result-type = type | "void" ;

callable-type =
    [ "async" ], callable-inputs, "->", result-type, [ error-contract ] ;

callable-inputs = "||" | "|", type, { ",", type }, "|" ;

generic-parameters = "<", identifier, { ",", identifier }, ">" ;
generic-arguments = "<", generic-argument, { ",", generic-argument }, ">" ;
generic-argument = type | integer-literal ;
```

Callable types use pipes around input types. `async` precedes the input list, and `raises` follows the result. `void` is the special no-result type in a result position. To attach an error clause to a nested callable result, group that result. An ungrouped `raises` clause attaches to the innermost callable signature it can complete.

```no-ri
var filter: |string, integer| -> boolean
var shutdown: || -> void
var fetch: async |string| -> Response raises RequestError
var callback: (|integer| -> void)?
```

### Collection literals

Indexed literals use brackets. Map entries use `=>`. Named collection entries and named tuple components use `:`. A positional tuple uses parentheses and a comma to distinguish it from grouping. `set(...)` constructs a set.

```ebnf
indexed-literal = "[", [ expression, { ",", expression } ], "]" ;
map-entry = expression, "=>", expression ;
named-entry = identifier, ":", expression ;

keyed-literal =
    "{", [ map-entry, { ",", map-entry }
         | named-entry, { ",", named-entry } ], "}" ;

tuple-literal =
    "(", expression, ",", expression, { ",", expression }, ")"
  | "(", named-entry, { ",", named-entry }, ")" ;
```

The expected type distinguishes applicable collection types, including the type of an empty literal. Each generic collection defines its allowed arguments. `array<float, 3>` takes an element type and a fixed length. `map<string, integer>` takes key and value types. `list` denotes a heterogeneous list.

```no-ri
const samples: array<float, 3> = [1.0, 2.0, 3.0]
const names: sequence<string> = ["Ada", "Bo"]
const items: list = [10, "ready", :pending]
const unique: set<integer> = set(1, 2, 3)
const scores: map<string, integer> = {"Ada" => 95}
const person: collection = {name: "Ada", age: 30}
const point = (x: 10, y: 20)
const portion: slice<float> = samples[0..1]
```

The slice selects indices `0` and `1`.

### Generic declarations and application

Generic parameters follow the declared name. Explicit generic arguments follow the referenced name. In an expression, a contiguous `<` after a name starts generic application when the complete `<...>` is followed by `(`, `.`, or `::`. Otherwise `<` is a comparison. In type position, angle brackets delimit generic arguments. Nested generic lists may split `>>` into two closing delimiters.

```no-ri
identity<T> |item: T| -> T do
  item
end

const explicit = identity<integer>(42)
const inferred = identity(42)
const pair = Pair<integer, string>.initial(first: 10, second: "hello")
const matrix: list<list<integer>>
```

When explicit arguments are omitted, infer them by matching actual argument types against parameter types, including nested generic applications. Each generic parameter must have one consistent solution. Supply explicit arguments when inference cannot establish a unique solution.

## Objects and declaration containers

All no-ri values are objects. Their types define their properties and methods. Primitive and compound values use the same member access and invocation syntax.

| Full declaration | Shorthand |
| ---------------- | --------- |
| `entity object`  | `entity`  |
| `value object`   | `value`   |
| `variant object` | `variant` |

Each shorthand has the same meaning as its full form. A standalone `object` declaration follows entity grammar and semantics.

```ebnf
entity-declaration =
    decl-prefix, "entity", [ "object" ], identifier,
    [ generic-parameters ], [ "<", type ], [ conformance ],
    "begin", declaration-list, "end" ;

value-declaration =
    decl-prefix, "value", [ "object" ], identifier,
    [ generic-parameters ], [ conformance ],
    "begin", declaration-list, "end" ;

variant-declaration =
    decl-prefix, "variant", [ "object" ], identifier,
    [ generic-parameters ], [ conformance ],
    "begin", variant-member-list, "end" ;

object-declaration =
    decl-prefix, "object", identifier,
    [ generic-parameters ], [ "<", type ], [ conformance ],
    "begin", declaration-list, "end" ;

variant-case =
    [ visibility ], "case", identifier,
    [ "(", type, { ",", type }, ")" ] ;

conformance = "conforms", "to", type, { ",", type } ;
```

`< Base` names a single concrete parent where inheritance applies. `conforms to ProtocolA, ProtocolB` lists protocol conformances. Parenthesized types on a variant case declare its associated-value payload. A variant member list admits cases and declarations allowed by the variant object model.

```no-ri
value object Point begin
  const x: float
  const y: float

  initial |@x, @y| state
  end

  pub computed distance_from_origin: float do
    (x * x + y * y).sqrt()
  end
end

variant Status begin
  pub case pending
  pub case active
end

object Counter begin
  count: integer = 0

  pub increment! || do
    count += 1
  end
end
```

### Protocols

A protocol contains callable and property requirements. A callable requirement ends after its signature. A property requirement declares a type without stored state.

```ebnf
protocol-declaration =
    decl-prefix, "protocol", identifier,
    "begin", protocol-requirement-list, "end" ;

property-requirement = decl-prefix, identifier, ":", type ;

callable-requirement =
    "def", [ visibility ], [ "async" ], named-head, [ callable-parameters ],
    [ return-annotation ], [ error-contract ]
  | [ visibility ], [ "async" ], named-head, callable-parameters,
    [ return-annotation ], [ error-contract ] ;
```

```no-ri
protocol Describable begin
  description || -> string
end
```

## Modules and packages

### Implicit and explicit modules

The default module name is the source file’s basename without `.no-ri`. For example, declarations at file scope in `Accounts.no-ri` belong to the implicit module `Accounts`. Use an explicit `module ... begin ... end` declaration to name a module differently from its file or to declare multiple modules in one file. An explicit declaration using the file’s name is also valid. File-scope declarations outside explicit module blocks belong to the implicit module.

```no-ri
# Accounts.no-ri
pub currency || -> string do
  "JMD"
end
```

```ebnf
module-declaration =
    decl-prefix, "module", identifier, "begin", declaration-list, "end" ;

module-extension =
    [ "def" ], "extend", "module", qualified-name,
    "begin", declaration-list, "end" ;

import-declaration =
    "import", qualified-name, [ "from", string ], [ "as", identifier ] ;
```

`::` qualifies a name through a module or namespace. `.` selects a member. The global namespace supplies standard functions for unqualified calls. Module extensions are subject to package affiliation and access rules.

### Package defaults and file-level inclusion

For a source path one directory level deep, the containing directory supplies the default package name. For example, `Ledger/Accounts.no-ri` has implicit module `Accounts` and default package `Ledger`. A more deeply nested file declares its package affiliation explicitly. The package manifest `no-ri.toml` supplies project configuration.

A file-scope directive `package PackageName includes([...])` adds selected declarations from the current file to the named package. It can appear anywhere at file scope. Selections resolve after the complete file has been read.

```ebnf
package-inclusion =
    "package", qualified-name, "includes",
    "(", "[", package-entry, { ",", package-entry }, "]", ")" ;

package-entry = non-interpolated-string-literal ;
```

A `non-interpolated-string-literal` is a string literal containing no interpolation. Eligible declarations are modules, functions, constants, and variables defined at file scope in the current file. A function name selects its entire overload set. Including an explicit module gives its members that module’s package affiliation. Imports, local bindings, and members inside explicit module blocks are outside direct selection. An entry must identify an eligible declaration or one overload set.

The exact string `"*"` selects every eligible file-scope declaration. Multiple directives for the same package contribute to one set. Repeated selections have no additional effect. Explicit inclusion overrides default affiliation for the selected declarations. Unlisted declarations retain any applicable default affiliation. Explicitly including the same declaration in two different packages is an error, including through overlapping wildcard selections. Access modifiers and defaults continue to apply.

```no-ri
package Ledger includes(["Accounts"])

module Accounts begin
  const currency = "JMD"
end

default_currency || -> string do
  "JMD"
end

package Ledger includes(["default_currency"])
```

```no-ri
# Explicitly include every eligible declaration in this file.
package Ledger includes(["*"])
```

## Initialization

Construct an instance with `Type.initial(...)`. An initializer declaration uses `state ... end` and has no ordinary return annotation.

```ebnf
initializer-declaration =
    decl-prefix, [ "async" ], "initial", [ initializer-parameters ],
    "state", statement-list, "end" ;

initializer-parameters = "||" | "|", initializer-parameter-list, "|" ;

initializer-parameter-list =
    "..."
  | initializer-parameter, { ",", initializer-parameter }, [ ",", "..." ] ;

initializer-parameter =
    parameter | "@", identifier, [ "=", parameter-default ] ;
```

`initial` identifies the declaration when `def` and the empty parameter list are omitted. A property-bound parameter `@name` takes its type from the stored property and binds its argument before the `state` body. A mutable property-bound parameter can use the property default as its argument default. An explicit parameter default takes precedence for that argument.

Stored property defaults initialize their properties. An explicit initializer can initialize properties through property-bound parameters or assignments in its `state` body. A synthesized initializer uses declared property defaults and creates no memberwise parameters. A required property without a default needs an explicit initialization path.

A declaration-time default consumes a `const` property’s single initialization. The compiler rejects reads before initialization and checks that required state is initialized on every successful construction path.

### Parent initialization

If a child declares no initializer, construction calls `parent.initial()` with no explicit arguments. The call can use parent defaults and must resolve to one applicable initializer.

When construction uses a declared child initializer, the compiler normally inserts a parent call, forwarding matching child parameters by name. Omitted parent parameters can use defaults. A missing or ambiguous applicable initializer is a compile-time error.

A child initializer with an identical signature overrides the parent initializer and suppresses the automatic call. The override must call `parent.initial(...)` explicitly. Every successful construction path must establish parent initialization.

```no-ri
entity Shape begin
  const name: string

  initial |@name| state
  end
end

entity Circle < Shape begin
  radius: float = 1.0

  initial |name: string| state
    parent.initial(name: name)
  end
end

const unit_circle = Circle.initial(name: "unit circle")
```

## Properties, accessors, and mutation

Stored properties use the binding grammar. A computed property declares a type and uses either a simple executable body or an explicit accessor list. A simple body supplies the property value.

```ebnf
stored-property = decl-prefix, binding ;

computed-property =
    decl-prefix, "computed", identifier, ":", type,
    "do", (statement-list | accessor-list), "end" ;

accessor-list = accessor, { NL, accessor } ;
accessor = getter | setter ;
getter = [ visibility ], "get", executable-body ;
setter = [ visibility ], "set", "|", setter-parameter, "|", executable-body ;
setter-parameter = identifier, [ ":", type ] ;
```

An explicit accessor body begins with an accessor header. It contains exactly one getter and at most one setter, in either order. An accessor inherits the property’s access and can narrow it. A setter takes one input. Its type defaults to the property type, and an explicit annotation must match.

```no-ri
pub computed balance: decimal do
  res set |amount| do
    balance_value = amount
  end

  get do
    balance_value
  end
end
```

### Assignment destinations and results

```ebnf
assignment = destination, assignment-operator, expression ;
destination = identifier | member-access | index-access | optional-access ;

assignment-operator =
    "=" | "+=" | "-=" | "*=" | "/=" | "%="
  | "&=" | "|=" | "^=" | "<<=" | ">>="
  | "&+=" | "&-=" | "&*=" ;
```

A destination must resolve to writable storage, an accessible setter, or existing storage eligible for first initialization with `=`. A `const` binding can refer to an entity with writable members. Mutating a value member requires a writable path to the enclosing value. Indexed writes require a collection that permits replacement. Tuple elements are immutable. Slice writes depend on the applicable mutable borrow.

Assignment operators associate right to left. `a = b = expression` groups as `a = (b = expression)`. The rightmost expression is evaluated once. Each assignment completes its write and yields the value supplied to its destination after any permitted conversion.

Plain computed-property assignment passes the value to the setter and yields that input. Assignment uses neither a getter read after the write nor the setter’s own return value. In `a = obj.amount = 42`, `a` receives `42` when the setter accepts `42`, even if it stores a normalized value.

Compound assignment reads the destination, applies the underlying operator, writes the updated value, and yields the value supplied for that write. For a computed property, the getter supplies the original value and the setter receives the update. Receiver and index expressions used to locate the destination are evaluated once. Ordinary fixed-width arithmetic remains checked. `&+=`, `&-=`, and `&*=` wrap modulo \(2^N\) for an \(N\)-bit fixed-width integer.

An optional chain short-circuits when a receiver at an optional access is `nil`. For assignment, this skips the write and evaluation of its right-hand operand and yields `nil`. A successful optional assignment yields the supplied value as an optional result. The same rules apply to compound assignments.

```no-ri
counter += 1
flags |= mask
samples[index()] <<= 2
counter &+= 1
account.balance = 100

var assigned: decimal?
assigned = account?.balance = compute_balance()
```

## Control flow and errors

### If, elif, and else

An `if` has zero or more `elif` branches and an optional final `else`. Conditions are evaluated in order. The first matching branch runs. One `end` closes the chain.

```ebnf
if-form =
    "if", condition, "do", statement-list,
    { "elif", condition, "do", statement-list },
    [ "else", statement-list ], "end" ;

condition = expression | "const", identifier, "=", expression ;
```

`elif`, `else`, and `end` delimit the preceding statement list. A successful optional binding introduces an immutable name in its branch.

```no-ri
if score >= 90 do
  print("Excellent")
elif score >= 75 do
  print("Good")
else
  print("Keep going")
end

if const name = preferred_name do
  print(name)
elif const name = fallback_name do
  print(name)
else
  print("Guest")
end
```

### For and while

`for ... in ...` iterates over an iterable. A single binding receives one element per iteration. An outer comma requests keyed iteration, with the iterable providing a key and a value. A parenthesized binding destructures a single tuple. These forms can be combined.

```ebnf
for-form =
    "for", iteration-binding, "in", expression, executable-body
  | "for", identifier, "between", bound-expression,
    "and", expression, executable-body ;

iteration-binding = element-binding | identifier, ",", element-binding ;

element-binding =
    identifier
  | "(", element-binding, ",", element-binding,
         { ",", element-binding }, ")" ;

while-form = "while", expression, executable-body ;
```

```no-ri
for name in names do
  print(name)
end

for key, item in entries do
  print(key, item)
end

for (key, value) in tuples do
  print(key, value)
end

for key, (item_key, item_value) in entries do
  print(key, item_key, item_value)
end

while remaining > 0 do
  remaining -= 1
end
```

`while` tests its condition before each iteration. `while true` can be paired with `break`. The `for ... in ...` form is the language’s foreach loop. A collection may also expose `.each` as a method. Calling it with a closure does not create a loop target for `break` or `continue`.

```no-ri
names.each do |name|
  print(name)
end

names.each { |name| print(name) }
```

### Ranges

`..`, `..<`, `>..`, and `between` are binary, non-associative range operators. `between` produces an array containing the members of the inclusive range after removing its first and last members. If there are no interior members, the result is `[]`.

```ebnf
range-operator = ".." | "..<" | ">.." | "between" ;
```

| Expression    | Endpoints      | Example members |
| ------------- | -------------- | --------------- |
| `1..4`        | Both included  | `1, 2, 3, 4`    |
| `1..<4`       | End excluded   | `1, 2, 3`       |
| `1>..4`       | Start excluded | `2, 3, 4`       |
| `1 between 4` | Both excluded  | `2, 3`          |

In `for index between start and finish do`, the first outer-level `and` after `between` separates the bounds. An `and` within nested expression delimiters belongs to that expression. This header iterates over the same interior elements as `for index in start between finish do`.

```no-ri
const interior = 1 between 4
const empty = 1 between 2

for index in 1..3 do
  print(index)  # 1, 2, 3
end

for index between 1 and 4 do
  print(index)  # 2, 3
end
```

### Match

`match` evaluates its subject once and tests arms in source order. Each arm has a `do ... end` body. The optional `default` arm comes last. A guard follows the pattern and is evaluated only after the pattern matches.

```ebnf
match-form =
    "match", expression, "begin",
    match-arm, { NL, match-arm }, [ NL, default-arm ], "end" ;

match-arm = "case", pattern, [ "if", expression ], executable-body ;
default-arm = "default", executable-body ;

pattern = primary-pattern, { "|", primary-pattern } ;

primary-pattern =
    "_"
  | identifier
  | "^", identifier
  | literal-pattern
  | range-pattern
  | variant-pattern
  | "(", pattern, [ ",", pattern, { ",", pattern } ], ")"
  | "[", [ pattern, { ",", pattern } ], "]"
  | "{", [ keyed-pattern-entry, { ",", keyed-pattern-entry } ], "}" ;

literal-pattern =
    [ "-" ], numeric-literal
  | non-interpolated-string-literal | symbol-literal
  | "true" | "false" | "nil" ;

range-pattern = pattern-bound, range-operator, pattern-bound ;
pattern-bound = [ "-" ], numeric-literal | "^", identifier ;

variant-pattern =
    ( "." | qualified-name, "." ), identifier,
    [ "(", pattern, { ",", pattern }, ")" ] ;

keyed-pattern-entry =
    identifier, ":", [ pattern ]
  | literal-pattern, "=>", pattern ;
```

`_` matches any value without binding it. A bare identifier introduces an immutable binding in the guard and body. `^name` matches the value of an existing binding. Range patterns test membership. A variant pattern tests the case and any supplied payload patterns. Tuple and indexed patterns match by position and arity. A nonempty keyed pattern tests the listed keys and permits additional keys. `{}` matches an empty keyed collection. `name:` binds the corresponding keyed value as `name`. Alternatives must bind the same names with compatible types.

Normal arm completion finishes the match. `break` exits it. `continue` resumes testing the next arm against the original subject and can reach `default`. In nested constructs, `break` and `continue` target the nearest enclosing loop or match within the current executable body. In a loop, `break` exits and `continue` proceeds to the next iteration. A conditional branch does not introduce a control-transfer target.

A value-producing `match` must be exhaustive. Every path that completes the match normally must supply a compatible result. A match used as a statement can complete without selecting an arm.

```no-ri
const label: string = match result begin
  case .success(data) if data.ready?() do
    "Ready"
  end

  case .failure(_) do
    "Failed"
  end

  default do
    "Waiting"
  end
end
```

### Try, handle, and enforce

`try` opens a protected statement list. It can have multiple `handle` clauses and a final `enforce` clause. `enforce` runs cleanup when control leaves the construct. `raise` supplies an error value. A `raises` clause declares a callable’s error contract.

```ebnf
try-form =
    "try", NL, statement-list,
    (handler, { handler }, [ enforcement ] | enforcement), "end" ;

handler = "handle", identifier, ":", type, NL, statement-list ;
enforcement = "enforce", NL, statement-list ;

defer-form = "defer", executable-body ;
concurrent-form = "concurrent", executable-body ;
```

```no-ri
try
  const data = load(path)
  process(data)
handle error: ReadError
  report(error)
handle error: ParseError
  report(error)
enforce
  close_input()
end
```

`defer do ... end` schedules cleanup on scope exit. `await` applies to an asynchronous operation or result in an allowed context. `spawn` starts work from its supplied invocation. `concurrent do ... end` opens a structured concurrency scope.

### Trailing closures in control-flow headers

In `if`, `elif`, `while`, and `for` headers, the first outer-level `do` opens the control-flow body. The same rule applies to a `case` guard. Enclose a call with a trailing `do ... end` closure in parentheses when it appears in one of these header expressions. Include the entire call and its closure.

```no-ri
for item in (items.filter do |item| -> boolean
  item.active?
end) do
  print(item)
end
```

This applies to both bounds of the `for ... between ... and ...` form. The `do` inside the parentheses opens the closure. The outer `do` opens the control-flow body.

## Expressions and operator precedence

Primary expressions include literals, names, collection and tuple literals, grouped expressions, closure expressions, and value-producing control forms. Postfix operations extend an expression with member selection, optional selection, indexing, or invocation. Explicit grouping uses `(expression)`.

The levels run from highest to lowest.

| Level | Forms | Associativity |
| --- | --- | --- |
| 1 | Member access, optional access, indexing, invocation | Left |
| 2 | `**` | Right |
| 3 | Prefix `not`, `~`, `-` | Prefix |
| 4 | `*`, `/`, `%`, `&*` | Left |
| 5 | `+`, `-`, `&+`, `&-` | Left |
| 6 | `<<`, `>>` | Left |
| 7 | `&` | Left |
| 8 | `^` | Left |
| 9 | Bitwise OR (`\|`) | Left |
| 10 | Comparisons, equality, `same` | Non-associative |
| 11 | `and` | Left |
| 12 | `or` | Left |
| 13 | `..`, `..<`, `>..`, `between` | Non-associative |
| 14 | `??` | Right |
| 15 | `=` and compound assignment | Right |

Postfix chains group in source order. `rows[i].transform()(x)` indexes `rows`, selects and invokes `transform`, then invokes the returned callable with `x`. Exponentiation accepts a unary expression on its right. `2 ** -3` is valid syntax, and `-2 ** 2` groups as `-(2 ** 2)`. Consecutive operators at a non-associative level require explicit grouping.

Boolean operations use `and`, `or`, and `not`. `and` and `or` short-circuit. `??` evaluates its left operand once. It unwraps and yields a present value, or evaluates and yields its fallback when the left operand is `nil`. A present `false` or `0` remains the result.

```no-ri
const display = preferred_name ?? account_name ?? "Guest"
const indices = 1..(limit ?? 10)
```

The first expression groups as `preferred_name ?? (account_name ?? "Guest")`. Range operators bind more tightly than coalescing, so `start..limit ?? fallback` groups as `(start..limit) ?? fallback`. Assignment groups to the right under the rules in [Assignment destinations and results](#assignment-destinations-and-results).

## Related specifications

[Arguments](arguments.md) · [Closures](closures.md) · [Collections](collections.md) · [Concurrency](concurrency.md) · [Control flow](control-flow.md) · [Entity](entity.md) · [Errors](errors.md) · [Functions](functions.md) · [Generics](generics.md) · [Initial state](initial-state.md) · [Modules](modules.md) · [Namespaces](namespaces.md) · [Operators](operators.md) · [Packages](packages.md) · [Properties](properties.md) · [Protocols](protocols.md) · [Reflection](reflection.md) · [Types](types.md) · [Value objects](value_object.md) · [Variables](variables.md) · [Variants](variant.md) · [Language reference](README.md)
