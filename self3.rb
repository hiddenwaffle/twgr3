class C
  def set_v
    @v = 'instance variable that belongs to any instance of C'
  end

  def self.set_v
    @v = 'instance variable that belongs to C'
  end
end
