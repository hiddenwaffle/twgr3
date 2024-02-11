a = [1, 2, 3]
b = 100
a.each do |c; b|
  b = c
  puts "b: #{b}"
end
puts "b: #{b}"
