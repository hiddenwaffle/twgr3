# Notes for [_The Well-Grounded Rubyist, 3rd Edition_](https://www.manning.com/books/the-well-grounded-rubyist-third-edition)

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

`load()` checks the current working directory...

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

The method `gem()` can be used in programs to lock a specific version of a gem

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

* `dup()` duplicates objects
  * Shallow
* `freeze()` prevents undergoing changes
* `clone()` is like `dup()` but retains frozen status, if any
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

Can use `is_a?()` to determine an object's class hierarchy

```ruby
Magazine.new.is_a?(Publication)
```

## Chapter 4 - Modules and program organization

* `Kernel` is a module that `Object` mixes in
  * It is where most of Ruby's fundamental methods are defined

* `prepend` is like `include` but causes message lookup to the module before the class

* `ancestors()` shows the order of ancestors for a class or module

* `extend` makes a module's methods available as class methods
  * Does not add the module to the class's ancestor chain, unlike `prepend` and `include`

* `super` arguments
  * `super` (no argument list) _forwards_ the method's arguments to the super method
  * `super()` (empty argument list) sends _no_ arguments to the super method
  * `super(a, b, c, ....etc)` sends exactly those arguments to the super method

Get an instance of a method of an object

```ruby
f = obj.method(:hello)
sf = obj.method(:hello).super_method # nil if no super method

f.call # invoke the method
```

* Override `method_missing(method, *args, &block)` to handle any messages that an object does not respond to
  * Call `super` in `method_missing()` to delegate the missing method to the next ancestor

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


