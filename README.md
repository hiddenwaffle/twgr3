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

# Chapter 4 - Modules and program organization


