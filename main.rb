def print_each(a, b, n, actual)
  puts "---"
  m = midpoint(a, b, n)
  t = trapezoid(a, b, n)
  m_err = (m - actual).abs
  t_err = (t - actual).abs
  puts "------------------"
  puts "N = #{n}"
  puts "m: #{m.round(4)}"
  puts "t: #{t.round(4)}"
  puts "m_err: #{m_err.round(4)}"
  puts "t_err: #{t_err.round(4)}"
end

def calc_midpoint_xs(a, b, delta_x)
  i = a
  xs = []
  while i <= b
    xs << i
    i += delta_x
  end
  midpoints = []
  j = 0
  while j < (xs.size-1)
    midpoints << (xs[j] + xs[j+1])/2.0
    j += 1
  end
  midpoints
end

def midpoint(a, b, n)
  delta_x = (b-a)/n
  # puts "delta_x: #{delta_x}"
  xs = calc_midpoint_xs(a, b, delta_x)
  # puts "xs: #{xs.inspect}"
  acc = 0
  for x in xs
    value = f(x)
    # puts "value for #{x}: #{value}"
    acc += value
  end
  acc * delta_x
end

def calc_trapezoid_xs(a, b, delta_x)
  i = a
  xs = []
  while i <= b
    xs << i
    i += delta_x
  end
  xs
end

def trapezoid(a, b, n)
  delta_x = (b-a)/n
  # puts "delta_x: #{delta_x}"
  xs = calc_trapezoid_xs(a, b, delta_x)
  # puts "xs: #{xs.inspect}"
  acc = 0
  i = 1
  while i < xs.size-1
    value = f(xs[i])
    acc += value
    # puts "value for #{xs[i]}: #{value}"
    i += 1
  end
  first = f(xs.first)
  # puts "value for #{xs.first}: #{value}"
  last = f(xs.last)
  # puts "value for #{xs.last}: #{value}"
  (1.0/2.0)*delta_x*(first+(2*acc)+last)
end

def f(x)
  5.0*Math.exp(-2.0*x)
end

def main
  a = 0.0
  b = 2.0
  actual = 2.4542
  print_each(a, b, 4.0, actual)
  print_each(a, b, 8.0, actual)
  print_each(a, b, 16.0, actual)
  print_each(a, b, 32.0, actual)
end

main
