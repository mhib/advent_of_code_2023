require 'set'

@sum = 0

def number_of_matching(match, res)
  match = Set.new(match)

  res.count { match.include?(_1) }
end

def calculate_score(match, res)
  count = number_of_matching(match, res)
  return 0 if count == 0
  1 << (count - 1)
end

@cards = File.readlines('in.txt', chomp: true).map do |line|
  _, line = line.split(':')
  left, right = line.split('|')

  [left, right].map { _1.split(' ').map(&:to_i) }
end

p @cards.map { calculate_score(*_1) }.sum

@card_counts = Array.new(@cards.size, 1)

@card_counts.each_with_index do |count, i|
  matching = number_of_matching(*@cards[i])
  (i + 1).upto([i + matching, @cards.size - 1].min) do |next_idx|
    @card_counts[next_idx] += count
  end
end

p @card_counts

p @card_counts.sum