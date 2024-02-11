class Person
  def set_name(string)
    puts "Setting a person's name..."
    @name = string
  end

  def get_name
    puts "Returning the person's name..."
    @name
  end

  def species
    "Homo sapiens"
  end
end

joe = Person.new
joe.set_name('Joe')
puts joe.get_name

class Rubyist < Person
end

david = Rubyist.new
puts david.species
