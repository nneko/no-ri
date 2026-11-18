# Printing

echo, warn, and debug are standard functions available without a module or object qualifier.

| Function | Destination     | Default representation   |
| -------- | --------------- | ------------------------ |
| echo     | Standard output | Ordinary text            |
| warn     | Standard error  | Ordinary text            |
| debug    | Standard error  | Debugging representation |

warn adds no automatic warning prefix. debug remains active in release builds unless build configuration explicitly controls it.

## Options

All three functions share labelled output options.

| Option     | Default | Behaviour                            |
| ---------- | ------- | ------------------------------------ |
| separator  | " "     | Text between unformatted values      |
| terminator | "\n"    | Text appended after output           |
| format     | Omitted | Ruby-compatible printf format string |

```no-ri
echo("Hello, world!")
echo("Alice", 30)
echo("Alice", 30, separator: ": ")
echo("Loading...", terminator: "")
warn("Task not found")
debug(task)
```

Without format, values use ordinary or debugging text representations and are joined using separator. terminator is then appended, adding a newline by default.

## Format strings

format is the format string itself, not a boolean mode selector. Formatting follows Ruby printf conventions.

```no-ri
echo("Alice", 3, format: "%s has %d tasks")
echo(19.95, format: "Price: %.2f")
echo(7, format: "Item %03d")
echo(50, format: "%d%% complete")
```

The format controls conversion, flags, width, precision, and value combination. separator has no effect when format is supplied. terminator still applies; a newline within format does not suppress it.

Invalid formats and incompatible arguments report an error rather than silently producing misleading output. Mapping no-ri types to conversion directives, Ruby-compatible named-format arguments, and the diagnostic/error contract are specifications in development. Collection spread remains positional key/value tuples and does not create keyword arguments.

## Streams and terminals

echoing writes to standard streams and supports redirected output. Advanced colours, cursor operations, keyboard modes, and screen interfaces belong to the Console module.

## Specification in development

Complete callable signatures and option binding, format type mappings, named-format value sources, encoding, buffering, stream failures, format error types, and build controls for debug output.

[Console](console.md) · [I/O](io.md) · [Arguments](../language/arguments.md) · [Global namespace](../language/namespaces.md) · [Standard library](README.md)
