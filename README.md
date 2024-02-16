# Notes for [_The Well-Grounded Rubyist, 3rd Edition_](https://www.manning.com/books/the-well-grounded-rubyist-third-edition)

## Stray Observations

```ruby
# Find the source of a method
SecureRandom.method(:hex).source_location
# => ["/Users/myuser/.rbenv/versions/3.1.3/lib/ruby/3.1.3/random/formatter.rb", 73]
```

## Chapter 1 - Intro

Syntax check a file

```bash
ruby -cw main.rb
```

Find the Ruby installation

```bash
irb -r rbconfig
```

```ruby
RbConfig::CONFIG['bindir']
# Other keys: rubylibdir, archdir, sitedir, vendordir, sitelibdir, sitearchdir
# (./gems directory is not in this hash but should be next to the 'sitedir' value)
```

`load` checks the current working directory...

```ruby
load 'loadee.rb'
load '.../extras.rb'
```

...and then the _load path_ (`$:`)

```bash
ruby -e 'puts $:'
```

* `require_relative` is like `require` but can check the `cwd` (without manipulating the load path)

* Commonly used `ruby` command-line switches: `-c` (check), `-w` (warning), `-e` (execute literal) `-rname <feature>` (require)

```bash
rake --tasks
rake admin:list_documents
```

Install a gem from a local file

```bash
gem install /path/to/my.gem
```

```
gem install -l ... # restrict all operations to the local domain
gem install -r ... # prevent operations to the local domain
```

* Load path (`$:`) changes when `require` is used

The method `gem` can be used in programs to lock a specific version of a gem

```ruby
gem "bundler", "1.14.6" # Ruby
```

## Chapter 2 - Objects, methods, and local variables

```
obj = Object.new
def obj.talk
  puts 'I am an object'
end
```

Innate behaviors of an object

```ruby
p Object.new.methods.sort

[
  # ...
  :object_id,
  # ...
  :respond_to?,
  # ...
  :send, # or __send__
  # ...
]
```

Argument sponge

```ruby
def two_or_more(a, b, *c) # c is an array of the remaining args
  # ...
end
```

Default value

```ruby
def default_args(a, b, c=1)
  # ...
end
```

* `dup` duplicates objects
  * Shallow
* `freeze` prevents undergoing changes
* `clone` is like `dup` but retains frozen status, if any
  * Also shallow

## Chapter 3 - Organizing objects with classes

* Class methods can be overridden
  * Last definition wins

```ruby
Time.new.xmlschema # Errors
require 'time'
Time.new.xmlschema # Succeeds
```

* Syntactic sugar for methods whose names end in `=`

```ruby
ticket.price=(63.00)
# or
ticket.price = 63.00
```

* Methods whose names end in `=` return the assigned value, *not* the last value of the method

* `attr_reader`, `attr_writer`, `attr_accessor`

* `BasicObject` is above `Object` and is mostly used for DSLs
  * This is because is has very few methods of its own

Classes can be created like objects

```ruby
my_class = Class.new
instance_of_my_class = my_class.new

c = Class.new do
  def say_hello
    puts 'Hello!'
  end
end
```

`&:` uses a Proc object to simplify HOF calls

```ruby
['havoc', 'prodigy'].map(&:capitalize)
```

Ways to add a class method

```ruby
class Ticket
end
# ...
def Ticket.most_expensive(*tickets)
  tickets.max_by(&:price)
end

class Temperature
  def Temperature.c2f(celsius)
    celsius * 9.0 / 5 + 32
  end
  # ...
end
```

* Method notation in documentation
  * instance method: `Ticket#price`
  * class method: `Ticket.most_expensive` or `Ticket::most_expensive`

* Names of constants begin with a capital letter

* Class/module constants can be accessed outside of a class using `::`
  * Example: `Math::PI`

Some predefined constants in Ruby (these can also be seen with `ruby -v`)

```ruby
RUBY_VERSION
RUBY_PATCHLEVEL
RUBY_RELEASE_DATE
RUBY_COPYRIGHT
```

Use `<<` to add a new element to an existing array

```ruby
Ticket::VENUES << "Big Mike's Place" # Modifying the array that a constant references
```

Can use `is_a?` to determine an object's class hierarchy

```ruby
Magazine.new.is_a?(Publication)
```

## Chapter 4 - Modules and program organization

* `Kernel` is a module that `Object` mixes in
  * It is where most of Ruby's fundamental methods are defined

* `prepend` is like `include` but causes message lookup to the module before the class

* `ancestors` shows the order of ancestors for a class or module

* `extend` makes a module's methods available as class methods
  * Does not add the module to the class's ancestor chain, unlike `prepend` and `include`

* `super` arguments
  * `super` (no argument list) _forwards_ the method's arguments to the super method
  * `super` (empty argument list) sends _no_ arguments to the super method
  * `super(a, b, c, ....etc)` sends exactly those arguments to the super method

Get an instance of a method of an object

```ruby
f = obj.method(:hello)
sf = obj.method(:hello).super_method # nil if no super method

f.call # invoke the method
```

* Override `method_missing(method, *args, &block)` to handle any messages that an object does not respond to
  * Call `super` in `method_missing` to delegate the missing method to the next ancestor

* Modules are often used as namespaces

## Chapter 5 - The default object (self), scope, and visibility

* `self` references
  * In a class or module definition, self is the class or module object
  * In an instance-method definition, self will be some future object that calls the method
  * In singleton methods and class methods, self is the object that owns the method

Using self instead of class names

```ruby
class C
  def self.x
  end
end

class C
  class << self
    def x
    end
  end
end
```

* If a method name ends with an equal sign (i.e., setter), `self.method` must include the `self.` part, not just `method` by itself
  * Otherwise Ruby will think that you are creating a new variable

Every instance variable belongs to the current object (`self`) at that poin in the program. Notice the difference here:

```ruby
class C
  def set_v
    @v = 'instance variable that belongs to any instance of C'
  end

  def self.set_v
    @v = 'instance variable that belongs to C'
  end
end
```

* `require English` enables aliases for many built-in global variables
  * `$INPUT_LINE_NUMBER` instead of `$.`
  * `$PID` instead of `$$`
  * etc...

Prefix constants with `::` to start at the top-level

```ruby
class MyClass
  class String
  end

  def my_func
    ::String.new('I am a string') # Does not refer to MyClass::String
  end
end
```

* Class variables
  * Not class scoped; they are _class-hierarchy_ scoped
  * Shared between a class and instances of the class,
    * and shared between superclasses and subclasses
  * Two at-signs like `@@example` makes a class variable

Initializing a class variable

```ruby
class Car
  @@total_count = 0
  #...
end

# But it might be better as a class instance variable (notice the def self...)
class Car
  def self.total_count
    @total_count ||= 0
  end
  def self.total_count=(n)
    @total_count = n
  end
end
```

Can declare methods-access rules in classes multiple ways

```ruby
class X
  #...
  private
  def my_func
  end
end

class X
  #...
  def my_func
  end
  private :my_func
  #...
end
```

Private methods are inherited by subclasses

```ruby
class A
  private
  def cheese
    puts 'cheese'
  end
end

class B < A
  def please
    cheese
  end
end

B.new.please
```

Protected methods: these can be called on an object `x`, as long as the default object (self) is an instance of the same class as `x` or of an ancestor of descendant class of `x`'s class

```ruby
class C
  def initialize(n)
    @n = n
  end

  def n
    @n
  end

  def compare(c)
    if c.n > n # Able to do this because n is protected
      puts "The other object's n is bigger"
    else
      puts "The other object's n is the same or smaller"
    end
  end

  protected :n
end

c1 = C.new(100)
c2 = C.new(101)
c1.compare(c2)
```

Top-level methods are stored as private instances of the `Object` class

```ruby
def talk
  puts 'Hello'
end

# Equivalent to:
class Object
  private
  def talk
    puts 'Hello'
  end
end
```

All of the private instance methods that `Kernel` provides

```bash
ruby -e 'p Kernel.private_instance_methods.sort'
```

## Chapter 6 - Control-flow techniques

`!` has a higher precedence than `==`, so you need parentheses to do this check correctly

```ruby
if !(x == 1) # ...
if not x == 1 # ... (But do not need parentheses if using 'not' instead of !)
```

* `if` and `unless` statements evaluate to objects
  * If none of the clauses are true, it evaluates to nil

Can call a method in an `if` statement

```ruby
if m = /la/.match(name)
  # ... do something with m
end
```

* `case` statements
  * use the _case equality_ method, `===`
    * `a === b` says, "if I have a drawer labeled `a`, does it make sense to put `b` in it?
    * Example: `Integer === 2` is true, `Integer === 'hello'` is false
  * can have an `else` clause
  * like `if` statements, they evaluate to a single object

Match multiple values in a `case` statement by separating them with commas

```ruby
case answer
when 'y', 'yes' # matches both 'y' and 'yes'
  # ...
else
  # ...
end
```

`case` statements can be written with the keyword by itself, like `if...elsif` statements

```ruby
case
when x == 1, y == 2
  # ...
else
  # ...
end
```

`loop` examples

```ruby
n = 1
loop do
  puts n
  n = n + 1
  break if n > 9
end

n = 1
loop do
  puts n
  n = n + 1
  next unless n == 10 # next jumps to the beginning of the loop
  break
end
```

`while` can be placed at the end of a loop

```ruby
n = 1
begin
  puts n
  n = n + 1
end while n < 11
```

`until` can be used as an alterative to `while`

```ruby
n = 1
until n > 10
  puts n
  n = n + 1
end
```

`while` and `until` can be used in one-liners like `if` and `unless`

```ruby
n = 1
n = n + 1 until n == 10
```

Ruby does have a `for` loop

```ruby
for c in [1, 2, 3]
  # ...
```

Due to precedence, writing blocks with `{`/`}` can sometimes be favored over do`/`end`

```ruby
puts [1, 2].map do |n| n * 10 end   # \___These statements are equal;
puts([1, 2].map) do |n| n * 10 end  # /   unintended parens placement.
puts [1, 2].map  { |n| n * 10 }     # <-- Does the expected thing
```

The code block for `times` accepts a parameter, which is the iteration number

```ruby
5.times { |i| puts i } # Outputs "0\n1\n2\n3\n4", evaluates to 5
```

Blocks have direct access to variables that already exist

```ruby
def block_scope_demo_2
  x = 100
  1.times do
    x = 200
  end
  puts x
end
# => 200
```

Block-local variables are needed to say "give me a new variable x even if one already exists

```ruby
# Without block-local, final b will be 3:
a = [1, 2, 3]
b = 100
a.each do |c|     # <--------------- no semicolon
  b = c
  puts "b: #{b}"
end
puts "b: #{b}"

# With block-local, final b will still be 100
a = [1, 2, 3]
b = 100
a.each do |c; b|  # <--------------- semicolon b means "give me a new b for this block"
  b = c
  puts "b: #{b}"
end
puts "b: #{b}"
```

The beginning of a method or block provides an implicit `begin`/`end` context

```ruby
def foo
  # ...
  rescue
    # ...
end

bar do
  # ...
  rescue
    # ...
end
```

* `binding.irb` is one of the built-in methods for debugging

`&.` is the safe navigation operator, or dig operator

```ruby
nil&.does_not_exist
# => nil
```

Three ways to call `raise`

```ruby
raise
raise RuntimeError
raise RuntimeError, 'description'
```

A full Exception example

```ruby
class MyException < Exception # StandardError is another common parent class
end

begin
  raise MyException, '<---- oops ---->'
rescue MyException => e
  puts e.backtrace
  puts e.message
  raise # re-raises the exception
ensure
  puts 'This always runs'
end
```

## Chapter 7 - Built-in essentials

* Special overloaded methods can use Ruby's built-in syntactic sugar
  * `+ - * / % **`
  * `[] []= <<`
  * `<=> == > < >= <=`
  * `=== | & ^`
* Some overloaded methods have odd-looking syntax
  * Unary operators `+` and `-` become `def +@`, `def -@`
  * Logical not `!` and `not` become `def !`
* Example:

```ruby
obj = Object.new
def obj.+(other)
  'I am on strike from math'
end
puts obj + 100
```

* Bang `!` method recommendations
  * Don't use `!` except in `method`/`method!` pairs
  * Don't use `!` notation with destructive behaviors, or vice versa

Calling `to_a` on a `Struct` returns a summary of attribute settings

```ruby
Computer = Struct.new(:os, :manufacturer)
laptop1 = Computer.new('linux', 'Lenovo')
laptop2 = Computer.new('os x', 'Apple')
[laptop1, laptop2].map(&:to_a)
# => [["linux", "Lenovo"], ["os x", "Apple"]]
```

A _bare list_ means several identifiers or literal objects separate by commas (almost like pre-processing)

```ruby
[1, 2, 3, 4, 5] # a bare list within the literal array constructor brackets
```

A splat/star/unarray operator is `*` unwraps its operand into a bare list

```ruby
array = [1, 2, 3, 4, 5]
[*array]
# => [1, 2, 3, 4, 5]
```

* The `Integer` and `Float` methods are like more strict versions of `.to_i` and `.to_f`

"If an object responds to `to_str`, its to_str representation will be used when the object is used as the argument to `String#+.`

```ruby
class Bob
  def to_str
    'Bob'
  end
end
bob = Bob.new
'Hi ' + bob # Can also use the << operator
# => "Hi Bob'
```

`to_ary` helps you use objects like arrays

```ruby
class Bob
  def to_ary
    ['b', 'o', 'b']
  end
end
bob = Bob.new
[1, 2, 3].concat(bob)
# => [1, 2, 3, "b", "o", "b"]
```

* Booleans
  * `nil` and `false` have a Boolean value of false
  * Empty class definitions have a Boolean value of false
  * `true` and `false` are singleton objects of `TrueClass` and `FalseClass`
  * Boolean arguments in positional parameters can be hard to remember what they mean

* `nil` is a singleton object of `NilClass`

* `Object` defines three equality-test methods
  * `==`      - typically redefined by subclasses
  * `eql?`    - typically redefined by subclasses
  * `equal?`  - "are they the same object?"
    * Ruby recommends against redefining this

```ruby
# For Object, all three behave the same way
a = Object.new
b = Object.new
a == b      # false
a.eql?(b)   # false
a.equal?(b) # false

# For String, two behave the same way, one does not
string1 = 'text'
string2 = 'text'
string1 == string2      # true
string1.eql?(string2)   # true
string1.equal?(string2) # false

# For Integer and Float, == and eql? behave differently
5 == 5.0      # true
5.eql? 5.0    # false
5.equal? 5.0  # false
```

* `<=>` (spaceship operator)
  * `<`, `>`, `>=`, `<=`, `==`, `!=`, and `between?` are defined in terms of `<=>`
  * The `Comparable` module expects `<=>` to be defined
    * `-1` means less than
    * `0` means equal to
    * `1` means greater than

```ruby
class A
  # include Comparable # TODO: including this seems optional?

  attr_accessor :value

  def <=>(other)
    self.value <=> other.value
    # Or it could be written out explicitly:
    # if self.value < other.value
    #   -1
    # elsif self.value > other.value
    #   1
    # else
    #   0
    # end
  end
end
x = A.new
x = 10
y = A.new
y = 20
x < y   # => true
y < x   # => false
x == x  # => true
```

* Reflection
  * Class-level methods include:
    * `methods`
    * `public_instance_methods`/`instance_methods`
      * `instance_methods(false)` excludes the class's ancestors
      * `Object.instance_methods(false)` evaluates to `[]` (remember why?)
    * `private_instance_methods`
    * `protected_instance_methods`
  * Instance-level methods include:
    * `private_methods`
    * `public_methods`
    * `protected_methods`
    * `singelton_methods`
  * Including a module into a class affects objects that already exist because of how methods are looked up

## Chapter 8 - Strings, symbols, and other scalar objects

Alternatives to `'` and `"` quoting

```ruby
# %q{...} is literal, like a single-quoted string but allows single-quotes
%q{' " \n \t #{}}
# => "' \" \\n \\t \#{}"

# %Q{...} a.k.a. %{...} does interpolation and escaping, like a double-quoted string
%Q{' " \n \t #{}} # (%{} is synonymous with %Q)
# => "' \" \n \t "
```

Delimiters for `%`-style notations can be almost anything, not just `{...}`

```ruby
%q-A string-
%Q/Another string/
%[Yet another string]
```

* Heredocs
  * `<<HERE` includes any spaces
  * `<<-HERE` switches off the flush-left requirement (ending `HERE` can be in the middle of a line)
  * `<<~HERE` strips leading whitespace

Confusingly, the `<<HERE` does not have to be the last thing on its line

```ruby
[<<HERE.to_i * 10]
5
HERE
# => [50]
```

Basic string manipulation

```ruby
str = 'abcdefghijklmnopqrstuvwxyz'
str[-1]           # Last
# => "z"
str[6, 9]         # 9 characters starting at [6]
# => "ghijklmno"
str[6..9]         # [6] inclusive to [9] inclusive
# => => "ghij"
str['defg']       # Substring search (matched)
# => "defg"
str['asdf']       # Substring search (did not match)
# => nil
str[/q.*u/]       # Regex match
# => "qrstu"
```

To set part of a string to a new value, use `[]=`, which has the same indexing as `[]` above

```ruby
str = 'Hello'
str['ello'] = 'i'
str
# => "Hi"
```

* Methods to query strings include:
  * `include?`
  * `start_with?` and `end_with?`
  * `empty?`
  * `size`
  * `count` - Can count ranges, sets, negations, and more
  * `index`
  * `rindex` - Like `index`, but starts on the right
  * `ord` and `chr` take one character and are opposites
  * `encoding`

* Methods to transform strings include
  * `upcase`, `downcase`, `swapcase`, `capitalize`
    * These have `!` equivalents
  * `ljust`, `rjust`, `center`
  * `strip`, `lstrip`, `rstrip`
  * `chop` and `chomp`
  * `clear` - Notice that this modifies a String in-place but does not end in `!`
    * `replace` and `delete` are also the same way
  * `crypt` applies DES with salt
    * Example: `'secret'.crypt('salt')`
  * `succ`
  * `encode`

* Methods to convert strings include
  * `to_i`, `to_f`, `to_c`, `to_r`, `oct`, `hex`
  * `to_sym` a.k.a `intern`

Show the current file's encoding (usually UTF-8)

```ruby
puts __ENCODING___
```

UTF-8 escaped character

```ruby
"\u20AC"
# => "€"
```

* `to_s` creates a symbol programmatically

Arrays of strings or symbols can be grep'd

```ruby
['abc', 'bce', 'efg'].grep(/b/)
# => ["abc", "bce"]
```

* Symbols have very similar methods as strings
  * No bang (`!`) versions because symbols are immutable
  * Indexing (`[]`) into a symbol returns a string, not another symbol

Hex and octal

```ruby
0x12        # => 18
0x12 + 12   # => 30

012         # => 10
012 + 12    # => 22
012 + 0x12  # => 28
```

* `Date`, `Time`, and `DateTime` rely on the packages `date` and `time` for (full) functionality

```ruby
puts Date.today                 # 2023-01-11
puts Date.new(1959, 2, 1)       # 1959-02-01
puts Date.parse('2003/6/9')     # 2003-06-09
puts Date.parse('June 9, 2003') # Parse is pretty flexible
d = Date.today
d.day       # => 11
d.saturday? # => false
d.leap?     # => false
d >> 1
# => #<Date: 2023-02-11 ((2459987j,0s,0n),+0s,2299161j)>
                # ^^--- added 1 month (also see: next, next_year, next_month, prev_day, etc methods)
Date.today.rfc2822
# => "Wed, 11 Jan 2023 00:00:00 +0000"

Time.new                # => 2023-01-11 09:53:28.430124 -0600
Time.at(0)              # => 1969-12-31 18:00:00 -0600
Time.mktime(2007, 10, 3, 14, 3, 6)
# => 2007-10-03 14:03:06 -0500
Time.parse('2007-10-03 14:03:06 -0500')
# => 2007-10-03 14:03:06 -0500
t = Time.now
t.month   # => 1
t.sec     # => 29
t.sunday? # => false
t.dst?    # => false
t.strftime('%m-%d-%y')
# => "01-11-23"
t - 20    # => 2023-01-11 09:58:09.09056 -0600
                              # ^^--- subtracted 20 seconds
t >> 1

puts DateTime.new(2009, 1, 2, 3, 4, 5)            # 2009-01-02T03:04:05+00:00
puts DateTime.now                                 # 2023-01-11T09:55:42-06:00
puts DateTime.parse('October 23, 1973, 10:34 AM') # 1973-10-23T10:34:00+00:00
dt = DateTime.now
dt.year         # => 2023
dt.hour         # => 9
dt.minute       # => 57
dt.second       # => 41
dt.wednesday?   # => true
dt.leap?        # => false
dt.dst?
dt >> 2
# => #<DateTime: 2023-03-11T09:57:41-06:00 ((2460015j,57461s,51328000n),-21600s,2299161j)>
                    # ^^--- added two months (also see: next, next_year, next_month, prev_day, etc methods)
DateTime.now.httpdate
# => "Wed, 11 Jan 2023 16:04:31 GMT"
```

Iterate over a range of `Date` or `DateTime` objects

```ruby
d = Date.today
next_week = d + 7
d.upto(next_week) do |date|
  puts "#{date} is a #{date.strftime("%A")}"
end
# 2023-01-11 is a Wednesday
# 2023-01-12 is a Thursday
# 2023-01-13 is a Friday
# 2023-01-14 is a Saturday
# 2023-01-15 is a Sunday
# 2023-01-16 is a Monday
# 2023-01-17 is a Tuesday
# 2023-01-18 is a Wednesday
```

* Converting between `Time`, `Date`, and `DateTime`
  * `to_date`
  * `to_datetime`
  * `to_time`
  * `to_date`

## Chapter 9 - Collection and container objects

Hashes are ordered collections

```ruby
hash = { red: 'ruby', white: 'diamond', green: 'emerald' }
hash.each_with_index do |(key, value), i|
  puts "Pair #{i} is #{key}/#{value}"
end
# Pair 0 is red/ruby
# Pair 1 is white/diamond
# Pair 2 is green/emerald
```

Destructure an array

```ruby
(a, b) = [1, 2]
a # => 1
b # => 2
```

Special ways to create an array

```ruby
Array.new(3)
# => [nil, nil, nil]

Array.new(3) { |i| 10 * (i + 1) }
# => [10, 20, 30]

# Can you guess why this happens?
a = Array.new(3, 'abc')   # => ["abc", "abc", "abc"]
a[0] << 'def'             # => "abcdef"
a                         # => ["abcdef", "abcdef", "abcdef"]
# NOTE: Should have done this instead:
a = Array.new(3) { 'abc' }

# Array() tries to call to_ary, to_a, or just returns a 1-element array
obj = Object.new
def obj.to_a
  return [1, 2, 3]
end
Array(obj)
# => [1, 2, 3]
Array('hi')
# => ["hi"]

# %w and %W operators mean "words"; delimited by whitespace
%w(Joe Leo III)
# => ["Joe", "Leo", "III"]

# %W is parsed a like double-quoted string
%W(Joe is #{2018 - 1981} years old.)
# => ["Joe", "is", "37", "years", "old."]

# %i and %I are like %w and %W but for symbols
%i(Joe Leo III)
# => [:Joe, :Leo, :III]
```

`try_convert` is a common class method

```ruby
Array.try_convert(10)         # => nil
Array.try_convert([1, 2, 3])  # => [1, 2, 3]
```

Array syntactic sugar

```ruby
a = ['', 'second', 'third', 'fourth', 'fifth', 'sixth']

a[0] = 'first'      # equivalent
a.[]=(0, 'first')   # equivalent

a[0]                # equivalent
a.[](0)             # equivalent

# Get more than one element
a[1, 2]               # => ["second", "third"]
a[2..4]               # => ["third", "fourth", "fifth"]
a.slice(2, 3)         # => ["third", "fourth", "fifth"]
a.values_at(0, 2, 4)  # => ["first", "third", "fifth"]
```

Getting sub-array elements

```ruby
a = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
a.dig(1, 1)           # => 5
a.dig(100, 500, 55)   # => nil
```

* Ends of arrays
  * `unshift` and `shift`
  * `push` and `pop`
  * `<<` and `>>`

* Combining arrays
  * `concat`
  * `+`
  * `replace`

* Array transformations

```ruby
# * method joins arrays into strings, like `join`
a = %w(one two three)
a * "-"
# =>"one-two-three"

# compact removes nils
[1, nil, 2, nil].compact
# => [1, 2]
```

Sample n` random elements from array `a`

```ruby
a = [1, 2, 3, 4, 5]
a.sample()
# => 2          # which is random
a.sample(3)
# => [2, 5, 3]  # which is also random
```

* Hashes remember the insertion order of their keys
* Hash transformation: `select`, `reject`, `compact`, `replace`, and `clear` work on hashes similarly to arrays
  * `invert` flips the keys and values (but watch out for discarded duplicates)
* Hash querying: `has_key?`, `include?`, `key?`, `member?`, `has_value?`, `value`, `empty?`, `size`

Inclusive vs Exclusive Ranges

```ruby
r = 1..100  # inclusive [1,100]
r = 1...100 # exclusive [1,100)

r.begin
r.end
r.exclude_end?

r = 'a'..'z'
r.cover?('a')     # true
r.include?('a')   # true
r.cover?('abc')   # true
r.include?('abc') # false <-- behaves differently than cover?
r.cover?('A')     # false
r.include?('A')   # false

r = 1.0..2.0
r.include?(1.5)   # true
```

* Don't use backwards ranges; has unexpected behaviors

* `Set` is a standard library class, so it must be `require`d

```ruby
names = ['a', 'b', 'c']; name_set = Set.new(names) { |name| name.upcase }
# => #<Set: {"A", "B", "C"}>

name_set << 'd'
# => #<Set: {"A", "B", "C", "d"}>

name_set.delete('A')
# => #<Set: {"B", "C", "d"}>

# intersection: &
# union:        + or |
# difference:   -
# exclusive or: ^

# Example:
name_set + Set.new(['x', 'y', 'z'])
# => #<Set: {"B", "C", "d", "x", "y", "z"}>

# Merge
tri_state = Set.new(["Connecticut", "New Jersey"])
tri_state.merge(["New York"])
# => #<Set: {"Connecticut", "New Jersey", "New York"}>

# Other methods
# .subset?
# .proper_subset?
# .superset?
# .proper_superset?
```

## Chapter 10 - Collections central: Enumerable and Enumerator

* A class that includes `Enumerable` must defined an instance method named `each`.

```ruby
# Shows methods defined by Enumerable that are now accessible as a result of defining an each method
Enumerable.instance_methods(false).sort
```
* `Enumerable` has queries such as: `include?`, `all?`, `any?`, `one?`, `none?`
* Float and integer ranges are handled differently (e.g., float ranges cannot be iterated)
* `Enumerable` has selection methods, such as `find`, `find_all`/`select`, `reject`

A failure-handling function can be given to `find`

```ruby
failure = lambda { 11 }
over_ten = [1, 2, 3, 4, 5, 6].find(failure) { |n| n > 10 }
```

Example `reject`

```ruby
a = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
a.reject { |item| item > 5 }
# => [1, 2, 3, 4, 5]
```

`Enumerable#grep` uses "threequal" (`===`, the "case-equality operator")

```ruby
colors = %w(red orange yellow)
colors.grep(/o/)
# => ["orange", "yellow"]

# grep has a built-in map over matched
colors.grep(/o/) { |color| color.capitalize }
# => ["Orange", "Yellow"]

# Ranges implement === as an inclusion test
range = 10..20
# => 10..20
range.grep(15)
# => [15]
range.grep(21)
# => []
```

* The difference between `Enumerable#group_by` and `Enumerable#partition` is the return value (hash and array, respectively)
* `Enumerable#take` - get the first n elements
  * "Constrainable" with `take_while`
* `Enumerable#drop` - get everything but the first n elements
  * "Constrainable" with `drop_while`
* `Enumerable#max` and `Enumerable#min` work the way you would think

Relatives of `each`
* Self-explanatory: `reverse_each`
* `array.each_with_index` vs `array.each.with_index`

The `slice_` family

* `array.each_slice`
  * Block that takes `n` elements, _iterating over each group of `n`_
* `array.each_cons`
  * Block that takes `n` elements, _iterating over each index_
* `slice_before`, `slice_after` - group elements by a delimiter
  * Can be used to split up lines in a file by a delimiter
* `slice_when` - "test two elements at a time over a collection"

The `cycle` method

```ruby
class PlayingCard
  SUITS = %w(clubs diamonds hearts spades)
  RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)

  class Deck
    attr_reader :cards

    # @param [Integer] number of decks of cards
    def initialize(n=1)
      @cards = []
      SUITS.cycle(n) do |s|
        RANKS.cycle(1) do |r|
          @cards << "#{r} of #{s}"
        end
      end
    end
  end
end
```

The `inject` method, a.k.a. "reduce" or "fold"

```ruby
[1, 2, 3, 4].inject(0) { |acc, n| acc + n }
# => 10
[1, 2, 3, 4].inject(:+)
# => 10
```

* The `map!` version of `map` is actually defined on the classes that implement it, rather than `Enumerable`

`String` is not an `Enumerable`, just very similar
* `each_byte`, `each_char`, `each_codepoint`, `each_line`
* `$/` is what Ruby uses as the delimiter for `each_line`
* `bytes`

Enumerables are sorted by their spaceship operator `<=>`,
and if you want to _compare_ (`<`, `>`, `==`, `clamp`, `between?`, etc...), you must include `Comparable`

```ruby
class Item
  attr_accessor :price

  def <=>(other)
    self.price <=> other.price
  end
end

class ItemComparable < Item
  include Comparable
end
```

Sort blocks

```ruby
["2", 1, 5, "3", "4", "6"].sort { |a, b| a.to_i <=> b.to_i }
# => [1, "2", "3", "4", 5, "6"]

["2", 1, 5, "3", "4", "6"].sort_by(&:to_i)
# => [1, "2", "3", "4", 5, "6"]
```

* Enumerators
  * Are objects (whereas iterators are methods)
  * Have an `each` method that is used by the `Enumerable` module

```ruby
e = Enumerator.new do |y| # `y` is a "yielder"
  y << 1
  y << 2
  y << 3
end
e.to_a
# => [1, 2, 3]
e.map { |x| x * 10 }
# => [10, 20, 30]
# etc...
```

Attach an enumerator to another object (the enumerator's `each` serves as a front end to the array's `select`)

```ruby
arr = %w(a b c d)
e = arr.enum_for(:select)
e.each { |n| n.include?('a') }
# => ["a"]
```

Most built-in iterators return an enumerator when they are called without a block

```ruby
str = "Hello"
# These behave the same:
str.each_byte { |b| puts b }
(str.each_byte).each { |b| puts b }
```

Why use an enumerator? One reason is to protect a collection from mutations

```ruby
class PlayingCard
  def initialize
    @cards = ['J', 'K', 'Q', 'A']
  end

  def cards
    @cards.to_enum
  end
end

x.cards.map { |y| "Face Card: #{y}" }
# => ["Face Card: J", "Face Card: K", "Face Card: Q", "Face Card: A"]
x.cards << 'My Card'
# => undefined method `<<' for #<Enumerator [...]
```

* Enumerators have `next` and `rewind` methods
* "An enumerator attaches itself to a particular method on a particular object and uses that method as the foundation method -- the `each` -- for the entire enumerable toolset."

Enumerators help mitigate the problem of creating intermediate objects when method chaining

```ruby
string = 'An arbitrary string'
string.each_byte.map { |b| b + 1 }
# each_byte spawns an enumerator instead of an array
```

`with_index(1)` will start counting at 1 instead of 0

Full example: XOR a string
```ruby
class String
  def ^(key)
    kenum = key.each_byte.cycle
    each_byte.map { |byte| byte ^ kenum.next }.pack('C*').force_encoding(self.encoding)
  end
end

# Example:
x = 'hello' ^ 'world'
# => "\x1F\n\x1E\x00\v"
x ^ 'world'
# => "hello"
x ^ 'hello'
# => "world"
```

Lazy enumerators

```ruby
# This runs forever:
(1..Float::INFINITY).select { |n| n % 3 == 0 }.first(10)
# This terminates:
(1..Float::INFINITY).lazy.select { |n| n % 3 == 0 }.first(10)
# Alternatively:
(1..Float::INFINITY).lazy.select {|n| n % 3 == 0 }.take(10).force
```

## Chapter 11 - Regular expressions and regexp-based string operations

```ruby
# Syntax
//.class
# => Regexp
%r{}.class
# => Regexp

# Matching
/abc/.match?('123abc123')
# => true
'123abc123'.match?(/abc/)
# => true
/abc/ =~ '123abc123'
# => 3 # (numerical index; otherwise nil if no match)
'123abc123' =~ /abc/
# => 3 # (numerical index; otherwise nil if no match)
```
* Special characters: `^ $ ? . / \ [ ] { } ( ) + *`
* When using the `%r{}`, you do not have to escape `/`s

Character class examples

```ruby
%r{[dr]ejected}.match?('dejected')
# => true
/[a-z]/.match?('123')
# => false
/[a-zA-Z0-9]/.match?('123')
# => true
```

* Two ways to match any digit
  * `/[0-9]/`
  * `/\d/`
  * Match anything that isn't a digit by capitalizing: `/\D/`
    * Same for `\w`/`\W` (digit/alpha/_) and `\s`/`\S` (space/tab/newline)

`match?` vs `match` - the latter returns `MatchData`

```ruby
x = /1(.*)2(.*)3/.match('1-A-2=B=3')
# => #<MatchData "1-A-2=B=3" 1:"-A-" 2:"=B=">
x.string # or x[0]
# => "1-A-2=B=3"
x.captures[0] # or x[1] or $1
# => "-A-"
x.captures[1] # or x[2] or $2
# => "=B="
```

Nested captures

```ruby
/((a)((b)c))/.match('abc')
# => #<MatchData "abc" 1:"abc" 2:"a" 3:"bc" 4:"b">
```

Named captures

```ruby
re = %r{(?<first>\w+)\s+((?<middle>\w\.)\s+)(?<last>\w+)}
re = %r{(?<first>\w+)\s+((?<middle>\w\.)\s+)(?<last>\w+)}
x = re.match('Genghis X. Khan')
x[:first]
# => "Genghis"
x[:middle]
# => "X."
x[:last]
# => "Khan"
```

`?` directly after a capture paren means the capture is optional

```ruby
re = %r{(?<color>\w+)\s*((?<fruit>\w+)?)}
re.match('yellow banana')
# => #<MatchData "yellow banana" color:"yellow" fruit:"banana">
re.match('blue')
# => #<MatchData "blue" color:"blue" fruit:nil>
```

Other `MatchData` methods: `pre_match`, `post_match`, `begin`, `end`

* `?` means zero or one of the preceeding character or group
* `+` means one or more of the preceeding character or group

Greedy vs Non-Greedy
* `+?` is the non-greedy version of `+`
* `*?` is the non-greedy version of `*`

```ruby
/.*!/.match('abc!123!')
# => #<MatchData "abc!123!">
/.*?!/.match('abc!123!')
# => #<MatchData "abc!">
```

Specific numbers of repetitions

```ruby
# Exactly 3 digits then 4 digits
'123-1234'.match(/\d{3}-\d{4}/)
# => #<MatchData "123-1234">
'12-123'.match(/\d{3}-\d{4}/)
# => nil

# Between 1 and 10 digits
'1234567890'.match(/\d{1,10}/)
# => #<MatchData "1234567890">
'1'.match(/\d{1,10}/)
# => #<MatchData "1">
'a'.match(/\d{1,10}/)
# => nil

# 3 or more digits
'12345'.match(/\d{3,}/)
# => #<MatchData "12345">
'12'.match(/\d{3,}/)
# => nil

# Can you spot the difference?
/([A-Z]{5})/.match('David BLACK')
# => #<MatchData "BLACK" 1:"BLACK">
/([A-Z]){5}/.match('David BLACK')
# => #<MatchData "BLACK" 1:"K">
# It is because atoms include subpatterns wrapped in parentheses
```

Anchors:
* `^` and `$`
* `\A` beginning of string
* `\z` end of string
* `\Z` end of string, excluding newline, if any
* `\b` word boundary

Lookahead Assertions

```ruby
# "Zero-width positive lookahead assertion"
# Match three digits followed by a dot, but only return the three digits
str = "123 456. 789"
m = /\d+(?=\.)/.match(str)
# => #<MatchData "456">
```

Lookbehind Assertions

```ruby
# Match "BLACK" only when preceded by "David "
'David BLACK'.match /(?<=David )BLACK/
# => #<MatchData "BLACK">
'Jack BLACK'.match /(?<=David )BLACK/
# => nil
```

Non-Capturing Parentheses

```ruby
# "def" is not part of the MatchData
str = "abc def ghi"
# => "abc def ghi"
m = /(abc) (?:def) (ghi)/.match(str)
# => #<MatchData "abc def ghi" 1:"abc" 2:"ghi">
```

Conditional Matches

```ruby
# Match "b" if the first capture (#1) is matched; otherwise match "c"
str = "abc def ghi"
m = /(abc) (?:def) (ghi)/.match(str)
re = /(a)?(?(1)b|c)/ # or: /(?<first>a)?(?(<first>)b|c)/
re.match("ab")
# => #<MatchData "ab" 1:"a">
re.match("b")
# => nil
re.match("c")
# => #<MatchData "c" 1:nil>
```

Modifiers - These appear after the closing slash

* `/i` - case insensitive
* `/m` - multiline; useful to use with non-greedy wildcards
* `/x` - changes the meaning of whitespace; allows you to write comments

`Regexp.escape("...")` lets you escape normal strings so that they can be dropped into a regular expression

```ruby
/#{Regexp.escape('a.c')}/ # or Regexp.new('a.c')
#=> "a\\.c"
```

Example methods that use regular expressions:
`String#scan`, `String#split`, `String#sub`, `String#gsub`,
`StringScanner#scan_until`, `StringScanner#skip`
`Enumerable#grep`

Additionally, like `Enumerable#grep`, case statements use case equality (`===`) with regular expressions.

```ruby
case str
when `^y/i`
  # ...
when `^n/i`
  # ...
end
```

## Chapter 12 - File and I/O operations

`IO` Objects

* Familiarity with the C standard library helps with understanding `IO`'s API
* `IO` objects have methods like `puts`, `print`, and `write`
* `STDERR`, `STDIN`, and `STDOUT` are `IO` objects available to every program
* `IO` objects are enumerable: they have methods for iteration, such as `each`
  * Having `each` implies having methods like `select`
  * `$/` is the newline character for a given system, so `each` uses it to determine lines.
    It can be changed to something else the program needs it.
```ruby
$/ == "\n"
# => true
```

* `STDIN`, `STDOUT`, and `STERR` correspond to `$stdin`, `$stdout`, and `$stderr`
  * The global variables allow you to redirect to another `IO`, like `$stderr = $stdout`
* Input is retrieved through `gets` and `getc`
  * From the keyboard, by default

`File` objects

* `read` reads an entire file into a string
  * Also available as a class method
* `readlines` reads an entire file into an array of strings
  * Also available as a class method
* `readline` is similar to `gets` (but raises an error if reading past EOF)
  * Same for `readchar` and `readbyte` vs `getc` and `getbyte`
* `rewind` moves the position pointer back to the beginning
  * `pos` to get or set the current position
  * `seek` has different ways of setting the current position
* `Enumerable` methods are available through `IO` (i.e., `each`)
* `ungetc` puts a character onto the stream; opposite of `getc`
* Output modes
  * `w` write (creates a new file / overwrites an existing)
  * `a` append (creates a new file if needed)
* Metadata of a `File`
  * `size` gets the size of a file  * `exist?`
  * `empty?`
    * `zero?`
  * `directory?` / `file?` / `symlink?`
  * `readable?` / `writable?` / `executable?`
  * `File::Stat` has some other attributes
  * `file?` is it actually a file?
* `Kernel#test` is terser way of executing some of these queries

Directories

* `Dir` is similar to `File`
* `entries` returns an array of strings of the directory contents
* `Dir['myfile.*']` or `Dir.glob('myfile.*)` is like `ls myfile.*`
  * `glob` has optional argument bits
    * `File::FNM_CASEFOLD` for a case-insensitive search
    * `File::FNM_DOTMATCH` to match hidden files
* `mkdir`, `chdir`, `rmdir`/`unlink`/`delete`

Other file-related classes and modules

* `FileUtils` is a UNIX-like interface to files
* `FileUtils::DryRun` and `FileUtils::NoWrite` show potential outcomes of commands
* `Pathname`
  * Dissecting a path: `basename`, `dirname`, `extname`
  * `ascend` helps with navigation relative to the current directory
* `StringIO` treats strings like IO objects
  * Can be helpful when writing tests
* `Tempfile`
* `OpenURI` opens network resources as Files

```ruby
require 'open-uri'
OpenURI.open_uri('https://rubycentral.org')
x.class
# => Tempfile
x.size
# => 18734
```

## Chapter 13 - Object individuation

* Objects have two classes
  * The class of which it is an instance
  * Its singleton class
    * Obtainable through `object.singleton_class`
* Certain `Numeric` subclasses and symbols cannot have methods added to it
  * Everything else is fair game

`<< object` means the anonymous, singleton class of `object`

```ruby
# Two similar techniques
str = 'I am a string'
# Technique 1
class << str
  def twice
    self + ' ' + self
  end
end
# Technique 2
def str.twice
 self + ' ' + self
end
# NOTE: There is a scope difference between the two (page 419 uses class constants as an example)
```

Common to see `<< object` pattern used to define class methods

```ruby
# More similar techniques
# (there may be more scope or ordering differences here than noted)

class Ticket
  attr_accessor :price
  class << self
    def most_expensive(*tickets)
      tickets.max_by(&:price)
    end
  end
end

class << Ticket
  def most_expensive(*tickets)
    # ...
# ...

def Ticket.most_expensive(*tickets)
  # ...
# ...
```

* With respect to singleton classes, methods are encountered in the order of:
  1. Modules included in the singleton class
  1. The original class
  1. Modules included in the original class
* This implies that a module can be mixed in multiple times!

Use the `ancestors` method to see the hierarchy

```ruby
m = module M; end
o = Object.new
class << o
  include M
  ancestors
end
# => [#<Class:#<Object:0x000000010cd30f88>>, M, Object, PP::ObjectMixin, Kernel, BasicObject]
#        ^^^^^^^^^^^^-- o's singleton class  ^--- mixin to the singleton
```

Example of modifying a core Ruby class's method

```ruby
class String
  def shout
    "#{self.upcase}!"
  end
end
```

Aliasing methods
* `alias new old`
* `alias_method :new, :old`

