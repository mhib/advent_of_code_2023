MAX_COUNTS = {
  'red' => 12,
  'green' => 13,
  'blue' => 14
}

def is_valid?(game)
  MAX_COUNTS.each do |name, count|
    regex = /(\d+) #{name}/
    return false if game.scan(regex).any? { |c| c[0].to_i > count}
  end
  true
end

def get_power(game)
  MAX_COUNTS.each_key.map do |name|
    regex = /(\d+) #{name}/
    game.scan(regex).map { _1.first.to_i }.max || 0
  end.reduce(1, &:*)
end

@sum = 0

File.readlines('in.txt', chomp: true).each_with_index do |line, i|
  @sum += get_power(line)
end

p @sum