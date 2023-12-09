
def generate_new_sequence(input)
  all_zeros = true
  res = input.each_cons(2).map do |l, r|
    all_zeros = false unless l == r
    r - l
  end

  [res, all_zeros]
end

def new_value_first(input)
  rows = []

  current = input
  while true
    seq, stop = generate_new_sequence(current)
    break if stop
    rows << seq
    current = seq
  end

  acc = rows.last.last

  (rows.size - 2).downto(0) do |i|
    acc += rows[i].last
  end

  input.last + acc
end

def new_value_second(input)
  rows = []

  current = input
  while true
    seq, stop = generate_new_sequence(current)
    break if stop
    rows << seq
    current = seq
  end

  acc = rows.last.first

  (rows.size - 2).downto(0) do |i|
    acc = rows[i].first - acc
  end

  input.first - acc
end

sum = 0
File.readlines('in.txt', chomp: true).each do |l|
  sum += new_value_second(l.split(' ').map!(&:to_i))
end

p sum