def part_1(data)
  data.map do |s|
    arr = s.each_char.filter { |c| ('0'..'9').cover?(c) }
    arr.first.to_i * 10 + arr.last.to_i
  end.sum
end

NUMBERS = {
  'one' => 1,
  'two' => 2,
  'three' => 3,
  'four' => 4,
  'five' => 5,
  'six' => 6,
  'seven' => 7,
  'eight' => 8,
  'nine' => 9,
}

def part_2(data)
  data.map do |s|
    number_indexes = []
    s.each_char.with_index do |c, i|
      number_indexes << [c.to_i, i] if ('0'..'9').cover?(c)
    end
    NUMBERS.each do |word, number|
      0.upto(s.length - 1) do |i|
        if s[i, word.length] == word
          number_indexes << [number, i]
        end
      end
    end
    number_indexes.sort_by!(&:last)
    
    number_indexes.first.first * 10 + number_indexes.last.first
  end.sum
end

@data = File.readlines('in.txt', chomp: true).to_a

p part_1(@data)
p part_2(@data)