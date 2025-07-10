# 달 … 月 … Lua

## Numbers

### Floor Division

`//` "floor division", integer division, rounding toward negative infinity

```
> 3 // 2
1
> 3.0 // 2
1.0
```

### Modulo

`%` can also be implemented as a - ((a // b) * b)

Against a float:
```
> x = math.pi
> x - x%0.001
3.141
```

### Exponentiation

```
> 2^3
8.0
```

### Negation of Equality

```
> 5 ~= 5
false
> 5 ~= 6
true
```

### Math

Note, random/0 is [0,1), random/1 is [1,n].
Also, random always seeds from 1, so in real usages, set the `randomseed` first.

```
> math.huge
inf
> math.mininteger
-9223372036854775808
> math.maxinteger
9223372036854775807

> math.random()
0.30116260238927
> math.random(6)
1
> math.random(6)
6
> math.random(5, 10)
10
> math.randomseed(os.time())
1748384633 0

> math.modf(3.5)
3 0.5
> math.modf(-3.5)
-3 -0.5
> x = math.modf(3.8)
> x
3
> x, y = math.modf(3.8)
> y
0.8
```

#### Rounding

Unbiased rounding, i.e., round toward the closest even number.

```lua
function round(x)
	local f = math.floor(x)
	if (x == f) or (x % 2.0 == 0.5) then
		return f
	else
		return math.floor(x + 0.5)
	end
end
```

```
> dofile("round.lua")
> round(3.5)
4
> round(2.5)
2
```

### Force Integer

OR with zero, as long as number is in valid integer range.

```
> 2^53 | 0
9007199254740992
> 3.2 | 0
stdin:1: number has no integer representation
```

or `math.tointeger/1` which returns `nil` when invalid.

## Strings

String length: `#"hello"` or `#str` counts in bytes, not characters.

Concat operator: `..`, so `"Hello " .. "World"` or `"result: " .. 3`

When using ASCII codes, may have to prefix with "0" depending upon string.
```
> "\49"
1
> "\492"
stdin:1: decimal escape too large near '"\492"'
> "\0492"
12
```

UTF:
```
> "\u{3b1} \u{3b2} \u{3b3}"
α β γ
```

`tonumber` to force String to Number, or `nil` if invalid.
```
> tonumber(" -3 ")
-3
> tonumber("100101", 2)
37
> tonumber("fff", 16)
4095
```

Repeat a letter:
```
> ("#"):rep(20)
####################
```

### Multiline

```
page = [[
<html>
  <head>
    <title>Test Page</title>
  </head>
  <body>
    <h1>Hi</h1>
  </body>
</html>]]
```

Can use equal sign to avoid stepping on `]]` usage, e.g., `[===[` only ends
with `]===]`.

Can use `\z` to skip following end-of-line character.

### String Library

```
> string.len("Éowyn")
6
> #"Éowyn"
6
> string.rep("-", 5)
-----
> string.reverse("Daines")
seniaD
> string.lower("Hi There")
hi there
> string.char(97)
a
> string.char(97, 98, 99)
abc
> string.byte("abc")
97
> string.byte("abc", 2)
98
> string.byte("abc", 1, 2)
97 98
> a = {string.byte("abc", 1, 2)}
> a[2]
98
> a = "[in brackets]"
> string.sub(a, 2, -2)
in brackets
> string.sub(a, 1, 1)
[
> string.sub(a, -1, -1)
]
> string.find("hello world", "wor")
7 9
```

### UTF-8

```
> s = "résumé"
> utf8.len(s)
6
> utf8.char(114, 233, 115, 117, 109, 233)
résumé
> utf8.codepoint(s, 6, 7)
109 233
> utf8.codepoint(s, utf8.offset(s, 2))
233
```

## Tables

Initialize with
```
> a = {}

> days = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
> days[2]
Monday

> a = {x = 10, y = 20}
> a.y
20

-- with mixed types, list-style starts at first declaration.
> polyline = {color = "blue",
              {x = 0, y = 0},
              {x = -10, y = 0}
             }
> polyline[1].x
0

-- to use non-standard identifiers.
> opnames = {["+"] = "add", ["-"] = "sub",
>> ["*"] = "mul", ["/"] = "div"}
> opnames["-"]
sub

-- trailing commas OK
> a = {[1] = "red", [2] = "green",}
> a[2]
green
```

A "sequence" is a "list" with no `nil` holes in it.
```lua
a = {}
for i = 1, 10 do
	a[i] = io.read()
end
```

Sequences can report length with `#`
```
> #a
10
> for i = 1, #a do
>> print(a[i])
>> end
-- add to end of list
a[#a + 1] = "v"
```

Holes cannot be counted
```
> b = {}
> b[1] = "a"
> b[3] = "c"
> #b
1
```

So, if you have to track length of a list with `nil`s in it, have to do it
yourself, typically in a value "n".

### Table Traversal

Element order is undefined, including per run.
```lua
for k, v in pairs(t) do
	print(k, v)
end
```

For lists use `ipairs`, which will ensure order, [1,n], which is same as
```lua
for k = 1, #t do
	print(k, t[k])
end
```

### Safe Navigation

What would be `zip = company?.director?.address?.zipcode` in a language like
C#, can be done with the following in Lua:
```lua
zip = (((company or {}).director or {}).address or {}).zipcode
```

### Table Library

Can `insert` and `remove` from sequence, moving other items in the process.
```
> l = {10, 20, 30}
> table.insert(l, 1, 15)
> l[1]
15
> l[2]
10
> table.remove(l, 2)
10
> l[2]
20
> table.remove(l)
30
> table.remove(l)
20
> table.insert(l, 5)
> l[2]
5
```

So, push is `table.insert(t, val)` and pop is `table.remove(t)`.
`table.insert(t, 1, val)` and `table.remove(t, 1)` work from head, but are
less efficient, but still relatively efficient up to a few hundred items.

Alternative, `move(a, f, e, t)` is equivalent to `insert(t, 1, x)`.
```lua
table.move(a, 1, #a, 2)
a[1] = x
```
And can be used to clone tables, `table.move(a, 1, #a, 1, {})`, or append one
list to another, `table.move(a, 1, #a, #b + 1, b)`.

## Functions

Lua parentheses are optional in one-argument functions.
```
print "Hello World"
print("Hello World")
```

Lua automatically passes `nil` for "missing" arguments and discard additional
arguments.
```
> function f (a, b) print(a, b) end
nil     nil
> f(3)
3       nil
> f(3, 4)
3       4
> f(3, 4, 5)
3       4
```

Without an explicit `return` statement, it is a `void` function.

Multi-return functions only return all values when the call is the last
expression in the list. Otherwise, only first result is captured.

Enclosing a multi-return function in parentheses returns only the first value.
We careful with `return`, which does not expect parentheses. `return(f(x))`
will only return one value, regardless of how many values `f` returns.

### Variadic Functions

```
function add(...)
	local s = 0
	for _, v in ipairs({ ... }) do
		s = s + v
	end
	return s
end

> add(3, 4, 10, 25, 12)
54
```

Can capture vararg expression
```
local a, b = ...
```

Multi-value identity function: `function id (...) return ... end`

If you need to capture variadic nils:
```
function nonils(...)
	local arg = table.pack(...)
	for i = 1, arg.n do
		if arg[i] == nil then
			return false
		end
	end
	return true
end

> nonils(2, 3, nil)
false
> nonils(2, 3)
true
> nonils()
true
```

Can also use `select` to handle varargs
```
> select(2, "a", "b", "c")
b       c
> select("#", "a", "b", "c")
3
```

This is a more performant version of `add` when there are few arguments, since
it doesn’t create new tables.
```
function add(...)
	local s = 0
	for i = 1, select("#", ...) do
		s = s + select(i, ...)
	end
	return s
end

> add(3, 4, 10, 25, 12)
54
```

### Unpack

For certain calls (like into C, which doesn’t accept varags), may need to use
`unpack`.

```
> table.unpack({10, 20, 30})
10      20      30
```

### Proper Tail Calls

Lua is properly tail recursive any time a function calls another function
(with `return`) as its last argument.

```lua
function foo(n)
	if n > 0 then
		return foo(n - 1)
	end
end
```

But any other action in the `return` eliminates the tail call.
```
return g(x) + 1  -- must still do addition
return x or g(x) -- must adjust to one result
return (g(x))    -- must adjust to one result
```

## The External World

`stdin` and `stdout` are as expected.

`io.read()` is from `stdin`, but can be swapped with `io.input(filename)`
It is shorthand for `io.input():read(args)`

`print` is really for quick-and-dirty output, use `io.write()` for real stuff.

`io.read` arguments:
- "a" reads whole file
- "l" reads next line (dropping newline)
- "L" reads next line (keeping newline)
- "n" read a number
- num read `num` characters as a string

`io.read(0)` tests for end of file. Empty string if more to read, `nil`
otherwise.

io.open takes arguments "r", "w", "a", and "b" (for binary)
```lua
local f = assert(io.open(filename, mode))
local t = f:read("a")
f:close()
```

Standard streams exist, too. `io.stdin`, `io.stdout`, and `io.stderr`
```lua
io.stderr:write(message)
```

Temporary file: `io.tmpfile`, automatically deleted when program ends.

`os.rename` and `os.remove` for file manipulation.

`os.execute` to run system commands.

For extended OS access, see `LuaFileSystem` library or `luaposix`, which
provides much of POSIX.1 standard.

## Filling Some Gaps

In interactive mode, each line is a chunk by itself, unless not a complete
command. This affects behavior of `local`.

`do`-`end` blocks can introduce scope, including when interactive.

Use `require("strict.lua")` module to error on attempting to assign to global
variables that haven’t been defined.

It is faster to use `local` variables, so prefer over global.

### Control Structures

if then else also supports `elseif` (there is no switch statement)

`while`

`repeat until` like `while`, but doesn’t test the condition until loop has
happened once.
```lua
local line
repeat
	line = io.read()
until line ~= ""
print(line)
```

Also, variables from body are visible in the test (unlike some languages)
```lua
-- Computes square root using Newton-Raphson method.
local sqr = x / 2
repeat
	sqr = (sqr + x / sqr) / 2
	local error = match.abs(sqr ^ 2 - x)
until error < x / 10000 -- local error still visible
```

`for` can be either "numerical" or "generic"

Numerical:
```lua
for var = exp1, exp2, exp3 do
	-- something
end
```
Is for each value from exp1 to exp2, incrementing by exp3. exp3 is 1 if
absent.

Use `math.huge` to loop without an upper limit.

All three expressions are evaluated before loop starts (i.e., calculations in
exp2 or exp3)

Use `break` to exit loop.

If need to save iterator, have to push to previously declared var.
```lua
local found
for i = 1, #a do
	if ... then
		found = i
		break
	end
end
```

Generic for traverses all values, such as with `ipairs` or `io.lines`.

`return` ... there is an implicit return for the last line of all functions.
Explicit return must be last statement in a block or just before `end`,
`else`, or `until`.
- To break anywhere else, need `do return end` to force it.

`goto` jumps to label. A label is surrounded by double colons, `::name::`.
Can be useful for writing state machines.

Labels are considered void statements, which allows them to appear before and
`end` and still return the value from the prior statement.
```lua
while some_condition do
	if some_other_condition then
		goto continue
	end
	local var = something
	-- more code
  ::continue::
end
```

## Closures

`function foo (x) return 2*x end` is syntactic sugar for
`foo = function (x) return 2*x end`

All functions are anonymous.

### Non-global Functions

These three examples are the same:
```lua
Lib = {}
Lib.foo = function(x, y) return x + y end
Lib.goo = function(x, y) return x - y end
```
... using constructors
```lua
Lib = {
	foo = function(x, y) return x + y end,
	goo = function(x, y) return x - y end,
}
```
... define into
```lua
Lib = {}
function Lib.foo (x, y) return x + y end
function Lib.goo (x, y) return x - y end
```

To define recursive local functions:
```lua
local fact
fact = function(n)
	if n == 0 then
		return 1
	else
		return n * fact(n - 1)
	end
end
```

To trampoline (not second `f` should not declare `local`:
```
local f

local function g ()
    <code> f() <code>
end

function f ()
    <code> g() <code>
end
```

### Lexical Scoping

Inside this function, `grades` is neither local or global, but `non-local
variable`, also called `upvalues` in some sources.
```lua
names = { "Peter", "Paul", "Mary" }
grades = { Mary = 10, Paul = 7, Peter = 8 }
function sort_by_grade(names, grades)
	table.sort(names, function(n1, n2)
		return grades[n1] > grades[n2]
	end)
end
```

Functions can escape the original scope of their variables:
```lua
function new_counter()
	local count = 0
	return function()
		count = count + 1
		return count
	end
end

c1 = new_counter()
print(c1()) --> 1
print(c1()) --> 2
```

Technically, what is a value in Lua is the closures, not the function. The
function itself is a kind of prototype for closures.

Lua allows monkey-patching. This is also used to allow sandboxing.

## Pattern Matching

Neither POSIX nor Perl regex are used in Lua (because they’d be too large).

Four functions in `string` library: `find`, `gsub`, `match`, and `gmatch`.

#### `string.find`

Returns starting and ending position. Third parameter is index to start at.
Fourth parameter boolean to use plain search (ignoring patterns).
```
> string.find("a [word", "[")
stdin:1: malformed pattern (missing ']')
> string.find("a [word", "[", 1, true)
3       3
```

#### `string.match`

Like `find`, but returns the matched bits.

```lua
date = "Today is 2025-06-09"
d = string.match(date, "%d+-%d+-%d+")
print(d) -- 2025-06-09
```

#### `string.gsub`

`string.gsub("Lua is cute", "cute", "great")`

Optional fourth argument limits number of substitutions.

Third argument can be a function or table!

#### `string.gmatch`

Returns function that iterates over all occurrences of a pattern.
```lua
s = "some string"
words = {}
for w in string.gmatch(s, "%a+") do
	words[#words + 1] = w
end
```

### Patterns

Character classes (upper-case version is compliment):
```
.   all characters
%a  letters
%c  control characters
%d  digits
%g  printable characters except spaces
%l  lower-case letters
%p  punctuation characters
%s  space characters
%u  upper-case letters
%w  alphanumeric characters
%x  hexadecimal digits
```

Magic characters: ( ) . % + - * ? [ ] ^ $
    `-` is 0 or more lazy repetitions

`%bxy` matches balanced strings.
```lua
s = "a (enclosed (in) parentheses) line"
print((string.gsub(s, "%b()", ""))) --> a  line
```

`%f[char-set]` represents a frontier pattern.
```lua
s = "the anthem is the theme"
print((string.gsub(s, "%f[%w]the%f[%W]", "one")))  --> one anthem is one theme
```

### Captures

```lua
pair = "name = Anna"
key, value = string.match(pair, "(%a+)%s*=%s*(%a+)")
print(key, value)  --> name    Anna
```

Can use `%` and a number to reference prior matches. %0 is the whole match.
```lua
s = [[then he said: "it's all right"!]]
q, quoted_part = string.match(s, "([\"'])(.-)%1")
print(q) --> "
print(quoted_part) --> it's all right
```

```
> print((string.gsub("hello Lua!", "%a", "%0-%0")))
h-he-el-ll-lo-o L-Lu-ua-a!
> print((string.gsub("hello Lua", "(.)(.)", "%2%1")))
ehll ouLa
```

```lua
function trim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end
```

### Replacements

Can pass tables or functions. If returns `nil`, then does not replace.
```lua
function expand(s)
	return (string.gsub(s, "$(%w+)", _G))
end

name = "Lua"
status = "great"
print(expand("$name is a $status, isn‘t it")) --> Lua is a great, isn‘t it
print(expand("$othername is $status, isn’t it")) --> $othername is great, isn’t it
```
(`_G` is all global variables.)

`()` captures the position in the string.
```
> print(string.match("hello", "()ll()"))
3       5
```

## Date and Time

Either number of seconds since epoch (1970 UTC), or a table that does NOT
include timezone, like:
```lua
{year = 1998, month = 9, day = 16, yday = 259, wday = 4, hour = 23, min = 48,
sec = 10, isdst = false}
```

`os.time()` returns seconds, or can be passed a date-time to get seconds of
that date.

```
> os.time({year = 1992, month = 5, day = 1})
704746800
```

To produce a date table:
```
> os.date("*t", os.time())
{year = 2025, month = 6, day = 16, yday = 167, wday = 2,
 hour = 13, min = 23, sec = 31, isdst = true}
```

Or pass format string (which will use current locale). `!` interprets time as
UTC. See pg 112 for table of directives.
```
> print(os.date("a %A in %B"))
a Monday in June
> print(os.date("%Y-%m-%d", 906000490))
1998-09-16
> print(os.date("%Y-%m-%dT%H:%M:%S"))
2025-06-16T13:33:01
> print(os.date("!%c", 0))
Thu Jan  1 00:00:00 1970
> print(os.date("!%Y-%m-%dT%X%z"))
2025-06-16T20:38:58-0800
```

`os.time` will normalize times.
```
> t = os.date("*t")
> print(os.date("%Y-%m-%dT%X", os.time(t)))
2025-06-16T13:40:55
> t.day = t.day - 40
> print(os.date("%Y-%m-%dT%X", os.time(t)))
2025-05-07T13:40:55
```

`os.difftime` returns different in seconds.
```
> os.difftime(os.time(t), os.time())
-3456421.0
```

Use `os.clock()` for sub-second precision, like timings.

## Bits and Bytes

Bitwise operators: `&`, `|`, `~` (exclusive OR), `>>`, `<<`.
    `~` is also unary operator for bitwise NOT
    Works against (64-bit) integers.

Can use this to treat an integer as unsigned.
```
> x = 3 << 62
> x
-4611686018427387904
> string.format("%u", x)
13835058055282163712
> string.format("0x%X", x)
0xC000000000000000
```

Math works fine, but unsigned division requires some handling (see
`unsigned_division.lua`).

`math.ult` is "unsigned less than" for comparing unsigned ints.

### Packing and Unpacking

`string.path(code, to_pack)` and `string.unpack(code, packed)`

Several options for coding an integer: "b" (char), "h" (short), "i" (int), "l"
(long), "j" (size of a Lua integer). To use a fixed, machine-independent size,
suffix "i", e.g., "i7" produces seven-byte integers. Uppercase makes it the
unsigned version.

Plenty more options, like "<" for big-endian and ">" for little-endian. See
Chapter 13 for options.

## Serialization

Can store and read files using `dofile` with data in the file looking like Lua
tables.

`string.format("%q", x)` safely serialized strings with problematic characters
and distinguishes between integer and float to ensure they are read back in
correctly.

## Compilation

`loadfile` is what does the hard work in `dofile` but does not raise errors,
returning error codes instead.

`load` reads from a string or function. But note that it only accesses global
variables, not local.
```lua
f = assert(load("i = i + 1"))
i = 0
f(); print(i) --> 1
f(); print(i) --> 2
```

These are equivalent: `loadfile(filename)` and `load(io.lines(filename, "*L"))`

"binary chunk" is a precompiled file (e.g., with `luac`)
Precompile with `luac -o prog.lc prog.lua`
Precompiled code files won’t necessarily be smaller, but will run faster.

### Errors

`error(message)` signals an error in the code. It can also be passed a
"level", like when you want to signal that the calling code passed an
incorrect argument.
```lua
function foo(str)
	if type(str) ~= "string" then
		error("string expected", 2)
	end
	-- code
end
```

`assert(fn_call, message)` ensures that first returned value is not `nil`,
otherwise raises an error with provided message. If no `message` is provided,
it will check for the second returned value and return that, hence the idiom
of `nil, error_code` as a return.

Note that Lua will always evaluate functions in the `message` argument, do be
careful of what you put in there.

Author’s guideline: An exception that is easily avoided should raise an error;
otherwise, it should return an error code.

`pcall` (protected call) is used to encapsulate our code to handle errors
instead of passing them out to the invoking application (like when Lua is
embedded). `pcall` unwinds (destroys) part of the traceback stack when
handling errors, so use `xpcall` which takes a message handler function if you
need a more detailed traceback, such as with `debug.traceback`.

## Modules and Packages

If you need to reload a library, erase it first.
`package.loaded.<modname> = nil`
Then the next `require` will pull it fresh.

Submodules are stored independently in the system, but are treated as filepath
separators when loading. For example,
`c = require('src.complex')`

Note that storing a module in `complex/init.lua` will load with
`require('complex')`, and this allow any submodules to exist alongside in that
same directory.

## Iterators and the Generic `for`

Use a factory that returns a function.
```lua
function values(t)
	local i = 0
	return function()
		i = i + 1
		return t[i]
	end
end

t = { 10, 20, 30 }
for element in values(t) do
	print(element)
end
```

Generic `for`:
```
for <var-list> in <exp-list> do
	<body>
end
```
The first variable in the list is the "control variable". When it becomes
`nil`, the loop ends.

Expression returns three variables kept by `for`: iterator function, invariant
state, and initial value for the control variable. If more than three
variables are returned, rest are dropped.

Equivalent to generic `for`:
```lua
do
    local _f, _s, _var = <explist>
    while true do
        local var_1, ..., var_n = _f(_s, _var)
        _var = var_1
        if _var == nil then break end
        <block>
    end
end
```

The following is equivalent to using `pairs(t)`:
```lua
for k, v in next, t do
    <loop body>
end
```

The above (using `for`) are technically "generators", but still commonly
referred to as "iterators". A true iterator operates as an independent
function. True iterators were more popular before introduction of `for`.

```lua
function all_words(f)
	for line in io.lines() do
		for word in string.gmatch(line, "%w+") do
			f(word)
		end
	end
end
```
which can be called like `all_words(print)`.

## Metatables and Metamethods

Metatables define behavior of an instance and do not have inheritance. Each
value in Lua has a metatable, but only tables and userdata have individual
metatables; all other values share a single metatable per type. Metatables for
non-tables cannot be set from within Lua, only from C or debug library.

`getmetatable(t)` and `setmetatable(t, meta)`

Metamethod names for arithmetic methods: `__add`, `__mul`, `__sub`, `__div`
(float), `__idiv` (integer), `__unm` (negation), `__mod` (modulo), `__pow`
(exponentiation)

Metamethod names for bitwise methods: `__band`, `__bor`, `__bxor`, `__bnot`,
`__shl`, and `__shr`.

Also `__concat`.

Relational metamethod: `__eq`, `__lt`, and `__le` (there are not "greater
than", they are covered by these.)
... if two objects have different basic types, `==` always returns false
without even calling a metamethod.

`__tostring` and `__len` (for `#t` override)

Can hide metatable from users with `__metatable`. This blocks writing.
```lua
mt.__metatable = "none of your business"
```

`__pairs` to implement a traversal function for object.

`__index` to override attempting to access an absent field. This is how you
set default values.
```lua
prototype = { x = 0, y = 0, width = 100, height = 100 }

mt.__index = function(_table, key)
	return prototype[key]
end
```

But this can be shortcut by providing a table: `mt.__index = prototype`

Can bypass `__index` by using `rawget(t, i)`.

`__newindex` and `rawset(t, k, v)` are for setting, which allows things like
read-only tables. (See pg. 195 for implementation.)

```lua
-- Set default value on any table.
function set_default(t, d)
	local mt = {
		__index = function()
			return d
		end,
	}
	setmetatable(t, mt)
end
```
which can be expensive, with new metatable and function for each table. This
stores default into a "hidden" field in the table itself.
```lua
local mt = {
	__index = function(t)
		return t.___
	end,
}

function set_default(t, d)
	t.___ = d
	setmetatable(t, mt)
end
```

20.2 (pg. 194) has an implementation if you need to track every call to a
table, using a proxy.

## Object-Oriented Programming

`:` has the effect of adding an extra (hidden) argument to a call. You can
define using `.` and call with `:` and vice versa. These are equivalent:
```lua
function Account.withdraw(self, v)
	self.balance = self.balance - v
end
```
```lua
function Account:withdraw(v)
	self.balance = self.balance - v
end
```

Lua is a prototype language (like Self and JS), so inheritance is via use of
prototypes, e.g., `setmetatable(A, {__index = B})`.

```lua
function Account:new(o)
	o = o or {}
	self.__index = self -- self is Account
	setmetatable(o, self)
	return o
end
```

For multiple inheritance, have to use a function for `__index` which calls
each parent prototype.

A common Lua practice is to mark private names with a trailing underscore.

Another way to force privacy it to separate state and operations (interface),
burying the state inside the other. Note that `self` doesn’t get passed as a
parameter.
```lua
function new_account(initial_balance)
	local self = { balance = initial_balance }

	local withdraw = function(v)
		self.balance = self.balance - v
	end

	local deposit = function(v)
		self.balance = self.balance + v
	end

	local get_balance = function()
		return self.balance
	end

	return {
		withdraw = withdraw,
		deposit = deposit,
		get_balance = get_balance,
	}
end
```

There is also a single-method approach and a dual-representation approach. See
pg. 206–208 for details.

## The Environment

Global vars are stored in `_G`. But this is a table like any other.

"Free name" is a name that is not bound to an explicit declaration. The
compiler converts any use of a free name `x` to `_ENV.x`. `_ENV` is created as
a local variable by the compiler outside any chunk that it compiles.

Usually, `_G` and `_ENV` point to the same table. `_ENV` always refers to the
current environment; `_G` will refer to the global environment unless changes
or not visible.

Can take advantage of this behavior in modules:
```lua
local M = {}
_ENV = M

function add(c1, c2)
	return new(c1.r + c2.r, c1.i + c2.i)
end
```
Or, preferable block from writing to global at all with
```lua
local M = {}
-- import needed functions.
local sqrt = math.sqrt
_ENV = nil
```

## Garbage

Weak tables are the mechanism to tell Lua that a reference should not prevent
garbage collection. Created with `__mode` of "k", "v", or "kv" to indicate
what is weak. `t = {__mode = "k"}` has weak keys. Only objects are removed as
weak; numbers and booleans are not collected on their own (e.g., weak keys
would not remove, weak values could be).

`collectgarbage()` to do a full collection. It takes a number of optional
arguments (pg. 233), mostly for when you’ve encountered a more serious issue
with a long-running program..

Using weak tables to enable memorization:
```lua
local results = {}
setmetatable(results, {__mode = "kv"})

function mem_load_string(s)
	local result = results[s]

	if result == nil then
		result = assert(load(s))
		results[s] = result
	end

	return result
end
```

Using dual representation to provide default values for a table. This solution
is better if few tables share common defaults.
```lua
local defaults = {}
setmetatable(defaults, { __mode = "k" })
local mt = {
	__index = function(t)
		return defaults[t]
	end,
}

function set_default(t, d)
	defaults[t] = d
	setmetatable(t, mt)
end
```

A solution that using distinct metatables. This one is better if you have
thousands of tables with a few distinct values.
```lua
local metas = {}
setmetatable(metas, { __mode = "v" })

function set_default(t, d)
	local mt = metas[d]

	if mt == nil then
		mt = {
			__index = function()
				return d
			end,
		}
		metas[d] = mt
	end

	setmetatable(t, mt)
end
```

An "ephemeron table" has weak keys but values that refer back to the keys.
These get garbage collected.
```lua
do
	local mem = {}
	setmetatable(mem, { __mode = "k" })

	function factory(o)
		local result = mem[o]

		if not result then
			result = function()
				return o
			end
			mem[o] = result
		end

		return result
	end
end
```

`__gc` is used to define a "finalizer", called on the object when garbage
collection happens. Finalization happens in reverse order that they were
marked for finalization. Finalization "resurrects" objects, to be sure that
this is transient and that finalization methods do not create permanent
references to the object being collected.

May need to set finalizer for nested object.
```lua
o = { x = "hi" }
mt = { __gc = true }
setmetatable(o, mt)

mt.__gc = function(o)
	print(o.x)
end

o = nil
collectgarbage()
```

Can use finalizers to create an "at exit" function. (This works because
globals are never garbage collected during runtime.)
```lua
local t = {
	__gc = function()
		print("finished Lua program")
	end,
}

setmetatable(t, t)
_G["*AA*"] = t
```

At each collection cycle, the collector clears values in weak tables before
calling finalizers, and clears keys afterward.

## Coroutines

Lua has “asymmetric coroutines”, meaning the function to suspend and resume
are different.

`coroutine.create(fn)` to create one. Can be in one of four states: suspended,
running, normal, and dead.

Use `coroutine.resume(co)` to (re)start execution. `coroutine.resume(co)`
runs in protected mode, returning any errors to the caller. Can pass
additional arguments, which will be passed into the function.

```
> co = coroutine.create(function() print("hi") end)
> type(co)
thread
> coroutine.status(co)
suspended
> coroutine.resume(co)
hi
true
> coroutine.status(co)
dead
```

`coroutine.yield()` can be called from within a coroutine to allow the caller
to decide the next step for execution. Can pass arguments, which will be
returned to the caller.

Common to use coroutines for iterators. See
[permutations.lua](src/permutations.lua) for an example. Pattern is so common
that API provides `coroutine.wrap(fn)`. `wrap` raises an error if encountered,
instead of returning it as first result like other functions in the module.

See [async-lib.lua](src/async-lib.lua), [reverse.lua](src/reverse.lua), and
[sync-async-reverse.lua](src/sync-async-reverse.lua) for event processing
examples.

## Reflection

`debug` modules breaks a lot of basic Lua assumptions, isn’t performant, and
should not be used in regular programs.

`debug.getinfo(arg)`:
- function arg returns table of information about a function.
- number arg is stack level, returns function info up call stack. `0` if for
  `getinfo` itself.
- optional second arg to limit which fields to return. (pg. 253)

`debug.traceback()` returns stack trace with info.

`debug.getlocal(level, index)` and `debug.setlocal(level, index, new_value)`
can be used to inspect local variables. Plenty of other options for querying
values, including globals and inside coroutines.

`debug.sethook(fn, mask, opt_count)` can add hooks to run on “call”, “return”,
“line”, or “count”. Use "c", "r", or "l" for mask. Call with no arguments to
turn off. Common to pass `debug.debug` as the function.

Debug can be used for profiling, but for timing questions, better to use C
library as overhead of Lua will mess with results.

Can also be used for sandboxing, such as limited call count or memory
consumption.
