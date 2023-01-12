hash = { red: 'ruby', white: 'diamond', green: 'emerald' }
hash.each_with_index do |(key, value), i|
  puts "Pair #{i} is #{key}/#{value}"
end
