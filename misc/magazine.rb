class Publication
  attr_accessor :publisher
end

class Magazine < Publication
  attr_accessor :editor
end

class Ezine < Magazine
end

mag = Magazine.new
mag.publisher = 'David A. Black'
mag.editor = 'Joe Leo'
puts "Mag is published by #{mag.publisher} and edited by #{mag.editor}."
