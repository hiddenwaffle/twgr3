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
