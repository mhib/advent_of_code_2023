@input = File.readlines('in.txt', chomp: true).to_a
@length = @input.size
@width = @input[0].size

NUMS = '0'..'9'
NEIS = [
  [-1, -1],
  [-1, 0],
  [-1, 1],
  [0, -1],
  [0, 1],
  [1, -1],
  [1, 0],
  [1, 1]
].map(&:freeze).freeze

def has_adjacent_symbol?(y, start, stop)
  start.upto(stop).any? do |x|
    NEIS.any? do |delta_y, delta_x|
      new_y = y + delta_y
      new_x = x + delta_x

      next false unless new_y < @length && new_y >= 0 && new_x < @width && new_x < @width

      char = @input[new_y][new_x]
      char != '.' && !NUMS.cover?(char)
    end
  end
end

def get_two_adjacent_number_coordinates(y, x)
  res = []
  NEIS.each do |delta_y, delta_x|
    new_y = y + delta_y
    new_x = x + delta_x

    next false unless new_y < @length && new_y >= 0 && new_x < @width && new_x < @width

    char = @input[new_y][new_x]
    next unless NUMS.cover?(char)

    # do not match the some row twice for same number
    # not that because of _1[0] == new_y and that NEIS are sorted
    # we know that the previous column was already visited in the current row
    # so we do not have to do negative index check for `new_x - 1`
    next if delta_y != 0 && res.any? { _1[0] == new_y && (_1[1] == new_x - 1 || NUMS.cover?(@input[new_y][new_x - 1])) }

    return nil if res.size >= 2
    res << [new_y, new_x]
  end
  return nil if res.size != 2
  res
end

def num_length(n)
  s = 0
  while n > 0
    s += 1
    n /= 10
  end
  s
end

def parse_adjacent(y, x)
  while x > 0 && NUMS.cover?(@input[y][x - 1])
    x -= 1
  end

  num = 0
  while x < @width
    c = @input[y][x]
    break unless NUMS.cover?(c)
    num *= 10
    num += c.to_i
    x += 1
  end

  num
end

def first
  sum = 0
  @input.each_with_index do |row, y|
    current_num = 0
    row.each_char.with_index do |c, x|
      if NUMS.cover?(c)
        current_num *= 10
        current_num += c.to_i
      elsif current_num > 0
        if has_adjacent_symbol?(y, x - num_length(current_num), x - 1)
          sum += current_num 
        end
        current_num = 0
      end
    end
    if current_num > 0 && has_adjacent_symbol?(y, @width - num_length(current_num), @width - 1)
      sum += current_num 
    end
  end
  sum
end

def second
  sum = 0
  @input.each_with_index do |row, y|
    current_num = 0
    row.each_char.with_index do |c, x|
      next unless c == '*'
      adjacent = get_two_adjacent_number_coordinates(y, x)
      next unless adjacent
      sum += adjacent.map { parse_adjacent(*_1) }.inject(:*)
    end
  end
  sum
end

p first
p second