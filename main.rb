class A
  attr_accessor :value

  def <=>(other)
    if self.value < other.value
      -1
    elsif self.value > other.value
      1
    else
      0
    end
  end
end
x = A.new
x = 10
y = A.new
y = 20
x < y
# => true
