//
// Token.swift
// No-Ri
//
// Represents a token in the no-ri programming language.
//
// Created by Nneko Branche on 2026/11/15.
//

public enum TokenType: String, Hashable, Sendable, CustomStringConvertible {

    // MARK: - Special tokens

    case EOF
    case INVALID
    //case LF
    //case CR

    // MARK: - Identifiers

    case Identifier

    // MARK: - Reserved keywords

    // MARK: - Declaration and Modifiers keywords
    case Async = "async"
    case Computed = "computed"
    case Constant = "const"
    case Define = "def"
    case Entity = "entity"
    case Extend = "extend"
    case Import = "import"
    case Initial = "initial"
    case Module = "module"
    case Object = "object"
    case Package = "package"
    case Protocol = "protocol"
    case Private = "prv"
    case Public = "pub"
    case Restricted = "res"
    case Value = "value"
    case Variable = "var"
    case Variant = "variant"

    // MARK: - Control Flow keywords
    case Begin = "begin"
    case Break = "break"
    case Case = "case"
    case Continue = "continue"
    case Default = "default"
    case Do = "do"
    case Elif = "elif"
    case Else = "else"
    case End = "end"
    case For = "for"
    case If = "if"
    case In = "in"
    case Match = "match"
    case Return = "return"
    case State = "state"
    case While = "while"

    // MARK: - Error Handling keywords
    case Raise = "raise"
    case Raises = "raises"
    case Try = "try"
    case Handle = "handle"
    case Enforce = "enforce"

    // MARK: - Concurrency keywords
    case Await = "await"
    case Concurrent = "concurrent"
    case Spawn = "spawn"
    case Defer = "defer"

    // MARK : - Delimiters and Separators

    case LeftParen = "("
    case RightParen = ")"
    case LeftBracket = "["
    case RightBracket = "]"
    case LeftBrace = "{"
    case RightBrace = "}"
    case Comma = ","
    case Colon = ":"
    case DoubleColon = "::"
    case Dot = "."
    case At = "@"
    case Arrow = "->"
    case DoubleArrow = "=>"
    case Bar = "|"
    case DoubleBar = "||"
    case Question = "?"
    case QuestionDot = "?."
    case DoubleQuestion = "??"
    /*
    case Hash = "#"
    case TripleHash = "###"
    case Continuation = "\\\n"
    */
    case Backslash = "\\"
    case RegexOpener = "%r{"

    // MARK: - Literals
    case Nil = "nil"
    case Void = "void"
    case Symbol = "symbol"

    // MARK: - Numeric Literals
    case Numeral = "numeral"

    // MARK: - String Literals

    // MARK: - Boolean Literals
    case True = "true"
    case False = "false"

    // MARK: - Types
    /*
    case BooleanT = "boolean"
    case ByteT = "byte"
    case StringT = "string"
    case IntegerT = "integer"
    case NumberT = "number"
    case FloatT = "float"
    case DecimalT = "decimal"
    case UIntT = "uint"
    case USizeT = "usize"
    case RefT = "ref"
    */

    // MARK: - Collection Types
    case Array = "array"
    case Collection = "collection"
    case List = "list"
    case Map = "map"
    case Set = "set"
    case Sequence = "sequence"
    case Slice = "slice"
    case Tuple = "tuple"

    // MARK: - Arithmetic Operators

    case Plus = "+"
    case Minus = "-"
    case Asterisk = "*"
    case DoubleAsterisk = "**"
    case ForwardSlash = "/"
    case Percent = "%"
    case AmpersandPlus = "&+"
    case AmpersandMinus = "&-"
    case AmpersandAsterisk = "&*"

    // MARK: - Bitwise Operators

    case Tilde = "~"
    case Ampersand = "&"
    case Hat = "^"
    case DoubleLessThan = "<<"
    case DoubleGreaterThan = ">>"

    // MARK: - Comparison Operators

    case DoubleEqual = "=="
    case NotEqual = "!="
    case LessThan = "<"
    case LessThanOrEqual = "<="
    case GreaterThan = ">"
    case GreaterThanOrEqual = ">="
    case Same = "same"

    // MARK: - Assignment Operators
    case Equal = "="
    case PlusEqual = "+="
    case MinusEqual = "-="
    case AsteriskEqual = "*="
    case ForwardSlashEqual = "/="
    case PercentEqual = "%="
    case AmpersandEqual = "&="
    case BarEqual = "|="
    case HatEqual = "^="
    case DoubleLessThanEqual = "<<="
    case DoubleGreaterThanEqual = ">>="
    case AmpersandPlusEqual = "&+="
    case AmpersandMinusEqual = "&-="
    case AmpersandAsteriskEqual = "&*="

    // MARK: - Range Operators
    
    case DoubleDot = ".."
    case TripleDot = "..."
    case DoubleDotLessThan = "..<"
    case GreaterThanDoubleDot = ">.."
    case Between = "between"
    
    // MARK: - Logical Operators
    case And = "and"
    case Or = "or"
    case Not = "not"

    // MARK: - Contextual Keywords
    /*
    case From = "from"
    case As = "as"
    case Includes = "includes"
    case Conforms = "conforms"
    case To = "to"
    case Get = "get"
    case SelfId = "self"
    case Parent = "parent"
    case Borrow = "borrow"
    case Mutate = "mut"
    case Take = "take"
    case Unsafe = "unsafe"
    */

    public var description: String {
        rawValue
    }
}