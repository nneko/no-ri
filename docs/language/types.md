# Types

no-ri is statically typed. The compiler infers types when unambiguous and rejects incompatible assignments.

## Syntax and examples

```no-ri
# ============================================================
# FILE: geometry.no-ri
# ============================================================

module Geometry begin

    # --------------------------------------------------------
    # PROTOCOLS
    # --------------------------------------------------------
    #
    # Protocols declare required properties and methods.
    # They do not own stored state.
    #
    # Requirements are public by default.
    # A required property may be satisfied by a stored
    # or computed property.

    pub def protocol Describable begin
        def describe -> string
    end

    pub def protocol Identifiable begin
        id: integer
        name: string
    end

    pub def protocol Measurable begin
        def area -> float
    end


    # --------------------------------------------------------
    # VALUE OBJECTS
    # --------------------------------------------------------
    #
    # Value semantics.
    # No concrete inheritance.
    # Protocol conformance supported.
    # Properties mutable unless const.
    # Members private unless explicitly exposed.
    #
    # Pure defaults are evaluated per instance.
    # They cannot suspend, mutate external state, or
    # access this, parent, or other instance properties.

    pub def value object Point conforms to Describable begin

        pub x: float = 0.0
        pub y: float = 0.0

        pub const label: string? = nil

        # Explicit constructor replaces the generated initial.
        #
        # The const label already has a default and therefore
        # cannot be assigned again in this constructor.

        pub def initial(@x: float, @y: float) do
        end

        pub def translate(dx: float, dy: float) -> Point do
            Point.initial(x + dx, y + dy)
        end

        pub def describe -> string do
            "Point(\(x), \(y))"
        end

        pub def computed distance_squared -> float do
            x * x + y * y
        end

    end


    # No explicit constructor is necessary because every
    # stored property has a valid default.

    pub def value Size begin

        pub width: float = 0.0
        pub height: float = 0.0

        pub def computed area -> float do
            width * height
        end

        pub def computed square? -> boolean do
            width == height
        end

    end


    # --------------------------------------------------------
    # ENTITY OBJECTS
    # --------------------------------------------------------
    #
    # Reference identity.
    # ARC-managed by default.
    # Single concrete inheritance.
    # Multiple protocol conformance.
    #
    # this   -> current instance
    # parent -> immediate ancestor

    pub def entity Shape conforms to Describable, Identifiable begin

        pub const id: integer
        protected name: string

        pub def initial(@id: integer, @name: string) do
        end

        pub def describe -> string do
            this.name
        end

        protected def rename!(name: string) do
            this.name = name
        end

    end


    pub def entity Circle < Shape conforms to Measurable begin

        private radius: float

        # id and name are forwarded to the parent constructor.
        # radius is initialized in this object.

        pub def initial(
            @id: integer,
            @name: string,
            @radius: float
        ) do
        end

        pub def area -> float do
            3.141592653589793 * radius * radius
        end

        pub def resize!(radius: float) do
            this.radius = radius
        end

        pub def computed diameter -> float do
            radius * 2.0
        end

        pub def describe -> string do
            "Circle(\(this.name), radius: \(radius))"
        end

    end


    pub def entity Rectangle < Shape conforms to Measurable begin

        private width: float
        private height: float

        pub def initial(
            id: integer,
            name: string,
            @width: float,
            @height: float
        ) do
            parent.initial(id, name)
        end

        pub def area -> float do
            width * height
        end

    end


    # --------------------------------------------------------
    # VARIANT OBJECTS
    # --------------------------------------------------------
    #
    # Closed sum types.
    # Value semantics.
    # No concrete inheritance.
    # No stored mutable instance state.
    # No side-effecting methods or async methods.
    #
    # Variants automatically conform to Describable.

    pub def variant Measurement begin

        pending
        success(float)
        failure(string)

        pub def success? -> boolean do
            switch this begin
                case success(value) do
                    true
                end

                default do
                    false
                end
            end
        end

        pub def computed value -> float? do
            switch this begin
                case success(number) do
                    number
                end

                default do
                    nil
                end
            end
        end

        pub def computed description -> string do
            switch this begin
                case pending do
                    "Pending"
                end

                case success(number) do
                    "Measurement: \(number)"
                end

                case failure(message) do
                    "Measurement failed: \(message)"
                end
            end
        end

    end

end


# ============================================================
# FILE: errors.no-ri
# ============================================================

import Error from "Foundation"

module ApplicationErrors begin

    # Error is a Foundation protocol.

    pub def variant ParseError conforms to Error begin
        invalid_input
        out_of_range
    end

    pub def value NetworkError conforms to Error begin

        pub code: integer
        pub message: string

        pub def initial(@code: integer, @message: string) do
        end

    end

end


# ============================================================
# FILE: application.no-ri
# ============================================================

import Geometry from "./geometry.no-ri" as Geo
import ApplicationErrors from "./errors.no-ri" as Errors

import Memory from "Foundation"
import Network from "Foundation"


module Application begin

    # --------------------------------------------------------
    # VARIABLES, CONSTANTS, AND INITIALIZATION
    # --------------------------------------------------------

    def demonstrate_variables do

        var count: integer = 10
        count = 20

        const maximum: integer = 100

        var total: integer
        total = 42

        const limit: integer
        limit = 1000

        # Optional declarations initialize to nil on
        # their first read if not previously initialized.

        var nickname: string?
        print nickname
        nickname = "Ada"

        const alias: string?
        print alias

        # alias is now initialized to nil.
        # It cannot be assigned another value.

        const display_name: string?
        display_name = "Grace"

        print display_name

    end


    # --------------------------------------------------------
    # PRIMITIVES AND OBJECT-STYLE BEHAVIOR
    # --------------------------------------------------------
    #
    # Primitive values have object-style methods without
    # requiring heap allocation or reference identity.

    def demonstrate_primitives do

        var enabled: boolean = true

        var raw: byte = 255

        var signed: integer = -42
        var unsigned: uint = 42

        var small: i8 = -12
        var medium: i32 = -1000
        var large: i64 = -100000

        var unsigned_small: u8 = 12
        var unsigned_medium: u32 = 1000
        var unsigned_large: u64 = 100000

        var huge: number = 123456789012345678901234567890

        var half: f16 = 1.5
        var single: f32 = 3.25
        var double: f64 = 3.141592653589793

        var ratio: float = 0.75
        var price: decimal = 19.95

        var index: usize = 1024

        var name: string = "Ada"
        var message = "Hello, \(name)"

        print signed.to_string()
        print ratio.to_string()
        print enabled.to_string()
        print message

        # Arithmetic is checked by default.
        # Integer division truncates.

        var quotient = 10 / 3
        var remainder = 10 % 3

        print quotient
        print remainder

    end


    # --------------------------------------------------------
    # OPTIONALS
    # --------------------------------------------------------

    def demonstrate_optionals do

        var name: string? = "Ada"

        var fallback = name ?? "Unknown"

        if const actual = name do
            print actual
        else do
            print "No name"
        end

        if var editable = name do
            editable = "Grace"
            print editable
        end

        var description: string? = nil
        description ??= "Default"

        var required = name.expect("Name required")

        print fallback
        print required

    end


    # --------------------------------------------------------
    # COMPOUND TYPES
    # --------------------------------------------------------

    def demonstrate_collections do

        # Fixed homogeneous array.

        var fixed: array<integer, 3> = [10, 20, 30]

        print fixed[0]
        print fixed[-1]

        fixed[1] = 25


        # Dynamic homogeneous sequence.

        var numbers: sequence<integer> = [10, 20, 30]

        numbers.append(40)
        numbers[0] = 5

        print numbers[-1]


        # Dynamic heterogeneous list.

        var mixed: list = [42, "Ada", true, 3.14]

        mixed.append("Grace")

        print mixed[0]
        print mixed[-1]


        # Homogeneous unique set.

        var unique: set<integer> = set(10, 20, 30)

        unique.add(40)


        # Homogeneous keyed map.

        var scores: map<string, integer> = {
            "Ada" => 95,
            "Grace" => 98
        }

        print scores["Ada"]

        scores["Ada"] = 100


        # Heterogeneous keyed collection.

        var person: collection = {
            name: "Ada",
            age: 36,
            active: true
        }

        print person.name
        print person["age"]

        person.age = 37
        person.city = "London"


        # Immutable heterogeneous tuple.
        # A var binding permits whole-tuple reassignment,
        # not mutation of individual elements.

        var location: tuple<3> = (
            latitude: 17.97,
            longitude: -76.79,
            name: "Kingston"
        )

        print location.latitude
        print location["longitude"]
        print location[0]
        print location[-1]

        location = (
            latitude: 18.0,
            longitude: -77.0,
            name: "Jamaica"
        )

    end


    # --------------------------------------------------------
    # GENERICS
    # --------------------------------------------------------

    def identity<T>(value: T) -> T do
        value
    end

    def value Box<T> begin

        pub item: T

        pub def initial(@item: T) do
        end

        pub def get -> T do
            item
        end

    end

    def demonstrate_generics do

        var number = identity(42)
        var text = identity("Hello")

        var box = Box<integer>.initial(100)

        print number
        print text
        print box.get()

    end


    # --------------------------------------------------------
    # FIRST-CLASS FUNCTIONS AND CLOSURES
    # --------------------------------------------------------

    def add(a: integer, b: integer) -> integer do
        a + b
    end

    def apply(
        value: integer,
        operation: (integer) -> integer
    ) -> integer do
        operation(value)
    end

    def make_multiplier(
        factor: integer
    ) -> (integer) -> integer do

        do (value: integer) -> integer
            value * factor
        end

    end

    def demonstrate_functions do

        # Named function used as a value.

        var operation = add

        print operation(10, 20)

        # Anonymous closure.

        var double = do (value: integer) -> integer
            value * 2
        end

        print apply(10, double)

        # Capturing closure.

        var triple = make_multiplier(3)

        print triple(10)

        # Function calls.

        print add(10, 20)
        print add(10, 20) * 2

        # Outermost parentheses may be omitted.

        print "Hello"

    end


    # --------------------------------------------------------
    # ANY AND EXPLICIT TYPE NARROWING
    # --------------------------------------------------------

    def demonstrate_any do

        var value: any = 42

        switch type(value) begin

            case integer do
                print value * 2
            end

            case string do
                print value
            end

            case boolean do
                print value
            end

            default do
                print "Unsupported type"
            end

        end


        var person: collection = {
            name: "Ada",
            age: 36,
            active: true
        }

        for key, item in person do

            switch type(item) begin

                case string do
                    print "\(key): \(item)"
                end

                case integer do
                    print "\(key): \(item * 2)"
                end

                case boolean do
                    print "\(key): \(item)"
                end

                default do
                    print "Unknown"
                end

            end

        end

    end


    # --------------------------------------------------------
    # LOOPS
    # --------------------------------------------------------

    def demonstrate_loops do

        var numbers = [10, 20, 30]

        for value in numbers do
            print value
        end

        # Inclusive range.

        for index in 0..9 do
            print index
        end

        # Exclusive upper bound.

        for index in 0..<10 do
            print index
        end

        var counter = 0

        while counter < 10 do

            counter += 1

            if counter == 3 do
                continue
            end

            if counter == 8 do
                break
            end

            print counter

        end

    end


    # --------------------------------------------------------
    # SWITCH
    # --------------------------------------------------------

    def demonstrate_switch do

        var status = 200

        # Block cases terminate automatically.

        switch status begin

            case 200 do
                print "Success"
            end

            case 404 do
                print "Not found"
            end

            default do
                print "Unknown"
            end

        end


        # Compact cases fall through unless terminated.

        switch status begin

            case 200:
                print "Success"

            case 201:
                print "Successful response"
                break

            case 404:
                print "Not found"
                break

            default:
                print "Unknown"

        end


        # Switch expression.

        const message = switch status begin

            case 200 do
                "Success"
            end

            case 404 do
                "Not found"
            end

            default do
                "Unknown"
            end

        end

        print message

    end


    # --------------------------------------------------------
    # OBJECT CONSTRUCTION
    # --------------------------------------------------------

    def demonstrate_objects do

        var point = Geo::Point.initial(10.0, 20.0)

        var copy = point

        var translated = point.translate(5.0, 10.0)

        print translated.describe()

        # Compiler-generated initial().

        var size = Geo::Size.initial()

        print size.area


        # Entities have reference identity.

        var circle = Geo::Circle.initial(
            1,
            "Circle A",
            10.0
        )

        var same_circle = circle

        circle.resize!(15.0)

        print same_circle.area()


        # Variant construction.

        var measurement = Geo::Measurement.success(42.0)

        print measurement

        switch measurement begin

            case pending do
                print "Pending"
            end

            case success(value) do
                print value
            end

            case failure(message) do
                print message
            end

        end

    end


    # --------------------------------------------------------
    # BORROWING AND OWNERSHIP
    # --------------------------------------------------------

    def inspect(point: borrow Geo::Point) do
        print point.x
    end

    def update!(point: borrow mut Geo::Point) do
        point.x += 1.0
    end

    def consume(point: take Geo::Point) do
        print point.describe()
    end

    def demonstrate_borrowing do

        var point = Geo::Point.initial(10.0, 20.0)

        inspect(point)

        update!(point)

        # Safe reference to initialized storage.

        var pointer: ref<Geo::Point> = ref(point)

        # ref.index returns a reference, not a value.

        var first = ref.index(pointer, 0)

        print deref(first).x

        # After the last active borrow ends, ownership
        # may be transferred.

        consume(point)

        # point can no longer be used after the move.

    end


    # --------------------------------------------------------
    # RAW MEMORY
    # --------------------------------------------------------

    def demonstrate_memory do

        var raw: unsafe ref<byte> = Memory::alloc(4096)

        var first = ref.unsafe_index(raw, 0)
        var next = ref.unsafe_offset(raw, 16)

        # Raw memory is uninitialized.
        # Pointer operations do not initialize objects.

        Memory::free!(raw)

    end


    # --------------------------------------------------------
    # DEFER
    # --------------------------------------------------------

    def demonstrate_defer do

        var raw = Memory::alloc(4096)

        defer do
            Memory::free!(raw)
        end

        # Cleanup runs at scope exit.

    end


    # --------------------------------------------------------
    # ERRORS
    # --------------------------------------------------------

    def parse_number(text: string) -> integer
        raises Errors::ParseError do

        if text == "" do
            raise Errors::ParseError.invalid_input
        end

        42

    end

    def demonstrate_errors do

        try do

            var result = parse_number("42")
            print result

        handle Errors::ParseError.invalid_input do
            print "Invalid input"
        end

        handle Errors::ParseError.out_of_range do
            print "Out of range"
        end

        ensure do
            print "Parsing completed"
        end

    end


    # --------------------------------------------------------
    # SYNCHRONOUS FUNCTIONS
    # --------------------------------------------------------

    def calculate(a: integer, b: integer) -> integer do
        a + b
    end


    # --------------------------------------------------------
    # ASYNCHRONOUS FUNCTIONS
    # --------------------------------------------------------
    #
    # An async function may suspend.
    # It does not have to contain await.
    #
    # Any function containing await must be async.

    def async fetch_data(url: string) -> string do
        await Network::get(url)
    end

    def async process_data(url: string) -> string do

        var response = await fetch_data(url)

        var number = calculate(10, 20)

        "\(response): \(number)"

    end


    # --------------------------------------------------------
    # ASYNC CLOSURES
    # --------------------------------------------------------

    def async execute(
        operation: async (string) -> string,
        url: string
    ) -> string do

        await operation(url)

    end

    def async demonstrate_async_closures do

        var fetch = async do (url: string) -> string
            await Network::get(url)
        end

        var result = await execute(
            fetch,
            "https://example.com"
        )

        print result

    end


    # --------------------------------------------------------
    # SPAWN AND OWNED TASK HANDLES
    # --------------------------------------------------------
    #
    # spawn may be used from synchronous code.
    # It returns an owned task handle.
    #
    # Moving the handle transfers ownership.
    # Dropping an unconsumed handle requests cancellation
    # and performs structured cleanup.

    def start_download(url: string) do
        spawn fetch_data(url)
    end


    # --------------------------------------------------------
    # STRUCTURED CONCURRENCY
    # --------------------------------------------------------

    def async download_both do

        concurrent do

            var first = spawn fetch_data(
                "https://example.com/a"
            )

            var second = spawn fetch_data(
                "https://example.com/b"
            )

            var result_a = await first
            var result_b = await second

            print result_a
            print result_b

        end

    end


    # --------------------------------------------------------
    # ASYNCHRONOUS ENTRY POINT
    # --------------------------------------------------------

    pub def async main do

        demonstrate_variables()
        demonstrate_primitives()
        demonstrate_optionals()
        demonstrate_collections()
        demonstrate_generics()
        demonstrate_functions()
        demonstrate_any()
        demonstrate_loops()
        demonstrate_switch()
        demonstrate_objects()
        demonstrate_borrowing()
        demonstrate_memory()
        demonstrate_defer()
        demonstrate_errors()

        # Synchronous function starts async work.

        var task = start_download(
            "https://example.com"
        )

        # Ownership of task belongs to main.

        var result = await task

        print result

        await download_both()

        await demonstrate_async_closures()

    end

end
```

Asynchronous object initialization example:

```no-ri
module Connections begin

    pub def entity Connection begin

        pub address: string
        pub connected: boolean = false

        pub def async initial(@address: string) do
            await Network::connect(address)
            this.connected = true
        end

        pub def async refresh! do
            await Network::refresh(address)
        end

        pub def computed active? -> boolean do
            connected
        end

    end


    # An async parent initial requires an async child initial.

    pub def entity SecureConnection < Connection begin

        pub encrypted: boolean = false

        pub def async initial(address: string) do
            await parent.initial(address)
            this.encrypted = true
        end

    end

end

# The caller must await initialization if it needs the constructed object:
pub def async main do

    var connection = await Connections::Connection.initial(
        "example.com"
    )

    await connection.refresh!()

    print connection.active?

end

# Alternatively a synchronous caller can instead spawn the construction:

def create_connection(address: string) do
    spawn Connections::Connection.initial(address)
end
```

## Semantics

| Type    | Meaning                             |
| ------- | ----------------------------------- |
| boolean | Boolean values                      |
| byte    | Byte representation                 |
| integer | Signed integer                      |
| uint    | Unsigned integer                    |
| number  | Arbitrary-precision numeric value   |
| float   | Default floating-point number       |
| decimal | Decimal arithmetic                  |
| string  | Unicode text                        |
| i8–i128 | Fixed-width signed integer family   |
| u8–u128 | Fixed-width unsigned integer family |
| f16–f64 | Floating-point family               |
| usize   | Platform-sized unsigned integer     |

Built-in types participate in the object model, including calls such as value.to_string(). Numeric overflow is checked by default. Wrapping and saturating operations require explicit mechanisms; their syntax is to be defined. Integer division follows integer semantics.

T? represents an optional value; nil represents absence. ?. performs safe member access, ?? supplies a fallback, if let conditionally unwraps, and unwrap() explicitly unwraps.

### Compound Types

| Type | Literal / declaration | Access | Mutation | Key rule |
| --- | --- | --- | --- | --- |
| array<T,N> | array<integer,3> | a[0], a[-1] | Replace elements | Fixed length, homogeneous |
| sequence<T> | [1,2,3] | s[0], s[-1] | Replace, append, remove | Dynamic length, homogeneous |
| list | [1,"Ada",true] | l[0], l[-1] | Replace, append, remove | Dynamic, heterogeneous |
| set<T> | set(1,2,3) | Membership operations | Add/remove | Unique, no positional indexing |
| map<K,V> | {"Ada" => 95} | m["Ada"] | Insert, replace, remove | Homogeneous keys and values |
| collection | {name:"Ada"} | c.name, c["name"] | Add, replace, remove | Heterogeneous named keys |
| tuple<N> | (name:"Ada",age:36) | t.name, t[0], t["name"] | Whole-value reassignment only | Immutable structure and elements |
| slice<T> | Borrowed view | s[0], s[-1] | Depends on mutable borrow | Non-owning, lifetime checked |

Indexed collections support negative indexing relative to the end. Safe indexing checks bounds. map indexing is based on its key type rather than position; collection is named-keyed rather than positional.

A statically known tuple key or index produces the concrete element type. Iterating a heterogeneous tuple, list, or collection exposes an any value when its concrete type cannot be determined statically.

## Rules and constraints

Assignments must respect both type compatibility and binding mutability. An invalid unwrap is not silently accepted.

An incompatible assignment is invalid. An invalid unwrap is not silently accepted.

```no-ri
var age: integer = 30
age = "thirty"  # invalid: incompatible type
```

### Invalid syntax and semantic rule violation examples

```no-ri
# ============================================================
# DECLARATION ERRORS
# ============================================================

# INVALID: no-ri has no let keyword.
let value = 42

# INVALID: async declaration order.
async def fetch do
end

# INVALID: void cannot be named as a return type.
def perform -> void do
end

# INVALID: executable statement in module body.
module Invalid begin
    print "Hello"
end

# INVALID: executable statement in protocol body.
def protocol Invalid begin
    print "Hello"
end

# INVALID: protocol owns no stored state.
def protocol Invalid begin
    count: integer = 10
end


# ============================================================
# INITIALIZATION ERRORS
# ============================================================

# INVALID: required property lacks initialization.
def value Credentials begin
    pub username: string
end

var credentials = Credentials.initial()

# INVALID: pure defaults cannot suspend.
def value Invalid begin
    pub data: string = await Network::get("example.com")
end

# INVALID: pure defaults cannot access instance state.
def value Invalid begin
    pub width: integer = 10
    pub height: integer = width * 2
end

# INVALID: const default already initializes the property.
def value Invalid begin
    pub const id: integer = 10

    pub def initial do
        this.id = 20
    end
end


# ============================================================
# TYPE ERRORS
# ============================================================

var values: sequence<integer> = [1, 2, 3]

# INVALID: incompatible element type.
values.append("hello")

var fixed: array<integer, 3> = [1, 2, 3]

# INVALID: fixed-size array cannot grow.
fixed.append(4)

var unique: set<integer> = set(1, 2, 3)

# INVALID: set has no positional indexing.
print unique[0]

var person: collection = {name: "Ada"}

# INVALID: collection has no positional indexing.
print person[0]

var location = (latitude: 17.97, longitude: -76.79)

# INVALID: tuple elements are immutable.
location.latitude = 18.0

# INVALID: tuple shape cannot change.
location.altitude = 100


# ============================================================
# ANY ERRORS
# ============================================================

var value: any = 42

# INVALID: operation requires integer narrowing.
print value * 2

# VALID narrowing is explicit:
switch type(value) begin
    case integer do
        print value * 2
    end
    default do
        print "Other"
    end
end


# ============================================================
# OBJECT MODEL ERRORS
# ============================================================

# INVALID: value objects have no concrete inheritance.
def value Child < Parent begin
end

# INVALID: entity supports one concrete parent.
def entity Child < ParentA, ParentB begin
end

# INVALID: variants have no async methods.
def variant Result begin
    success(string)

    def async refresh do
        await fetch_data("example.com")
    end
end


# ============================================================
# ASYNC ERRORS
# ============================================================

# INVALID: await in synchronous function.
def process do
    await fetch_data("example.com")
end

# INVALID: synchronous child of async-initialized parent.
def entity Child < AsyncParent begin
    def initial do
        parent.initial()
    end
end


# ============================================================
# OWNERSHIP ERRORS
# ============================================================

var point = Geo::Point.initial(1.0, 2.0)

consume(point)

# INVALID: use after ownership transfer.
print point.x

var raw = Memory::alloc(4096)

Memory::free!(raw)

# INVALID: double free.
Memory::free!(raw)

# INVALID: ordinary pointer arithmetic.
var next = raw + 1

# INVALID: raw storage cannot become a safe ref
# through an unchecked conversion.
var safe: ref<byte> = raw
```

## Language Rules

### Declarations and execution

`begin ... end` encloses declarations; `do ... end` encloses executable bodies. Modules, protocols, and object bodies are declarative. Standalone executable statements belong inside functions, methods, constructors, computed properties, or closures.

`def` introduces named functions, methods, protocols, and object declarations. `def async` introduces asynchronous functions. There is no `let`,` fn`, or `lambda` keyword.

### Types and objects

All first-class values support object-style behavior, including primitives and function values, without requiring universal boxing or heap allocation. Value objects and variants have value semantics; entities have reference identity and ARC-managed lifetimes.

Protocols may require properties or methods but cannot own stored properties. Variants are closed, value-semantic, and free of side-effecting or asynchronous methods. They automatically conform to `Describable`.

### Initialization

Pure property defaults are evaluated per instance. They cannot suspend, access instance state, or produce externally observable side effects.

A compiler-generated `initial()` is available when all required properties can be initialized through defaults or permitted implicit initialization. Explicit constructors replace the generated constructor.

`const` properties may be initialized exactly once. A default consumes that initialization opportunity.

`def async initial` is supported for values and entities. An entity inheriting an asynchronous parent constructor must use an asynchronous constructor. Partially initialized objects cannot escape.

### Functions and closures

Functions are first-class values. Anonymous closures use `do (parameters) -> Type ... end`; asynchronous closures use `async do (parameters) -> Type ... end`.

Closures preserve no-ri's ownership and borrowing rules. Escaping closures cannot retain invalid borrows; ownership transfers use take, and mutable borrowing must remain exclusive.

### Asynchronous execution

`await` is valid only in an asynchronous context. An `async` function is permitted, but not required, to suspend.

Synchronous code can initiate asynchronous work with `spawn`. A spawned task returns an owned handle; ownership may transfer to another scope or object. Dropping an unconsumed owned handle requests cancellation and structured cleanup.

`pub def async main` is a valid entry point. `concurrent do ... end` provides structured concurrency, and shared mutable state requires appropriate synchronization.

### Memory safety

`ref<T>` is a safe borrowed reference with lifetime and validity checks. `unsafe ref<T>` is a raw pointer without those guarantees. Pointer indexing and offsets use the ref operations rather than ordinary arithmetic, and those operations return references.

`Memory::alloc` produces uninitialized raw storage; `Memory::free!` releases eligible manually owned allocations. Memory::adopt establishes initialized managed ownership and consumes the original raw allocation owner. Its exact API remains a Foundation-level contract.

## To be defined

To be defined: Default integer widths, exact numeric representations, literal inference, conversion rules, division rounding for negative operands, overflow failure behavior, wrapping/saturating API, optional chaining result typing, invalid-unwrap failure mechanism, and boolean-compatible type set.

## Related specifications

[Variables](variables.md) · [Operators](operators.md) · [Numbers](../standard-library/numbers.md) · [Strings](../standard-library/strings.md)

[Section navigation](README.md) · [Specification status](../status.md)
