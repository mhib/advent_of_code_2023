require 'set'
require 'matrix'

map = File.readlines('in.txt', chomp: true).to_a

start = nil
map.each_with_index do |row, y|
  row.each_char.with_index do |c, x|
    if c == 'S'
      map[y][x] = '.'
      start = [y, x]
      break
    end
  end
  break if start
end

NEIS = [
  [-1, 0],
  [1, 0],
  [0, -1],
  [0, 1]
]


def find_possible_positions(map, start, count)
  length = map.size
  width = map[0].size

  is_pos_valid = lambda do |y, x|
    map[y][x] == '.'
  end

  visited = Set.new([start])

  count.times do |i|
    new_visited = Set.new

    visited.each do |y, x|
      NEIS.each do |delta_y, delta_x|
        new_y = y + delta_y
        new_x = x + delta_x
        next unless is_pos_valid[new_y, new_x]
        new_visited << [new_y, new_x]
      end
    end
    visited = new_visited
  end
  visited.size
end

def find_possible_positions_mod(map, start, count)
  length = map.size
  width = map[0].size

  is_pos_valid = lambda do |y, x|
    map[y % length][x % width] == '.'
  end

  res = []

  visited = Set.new([start])

  mod_to_find = count % length

  1.upto(1.0 / 0) do |i|
    new_visited = Set.new

    visited.each do |y, x|
      NEIS.each do |delta_y, delta_x|
        new_y = y + delta_y
        new_x = x + delta_x
        next unless is_pos_valid[new_y, new_x]
        new_visited << [new_y, new_x]
      end
    end

    if i % length == mod_to_find
      res << new_visited.length
      return res if res.size == 3
    end
    visited = new_visited
  end

end

p find_possible_positions(map, start, 64)


SECOND_COUNT = 26501365
ys = find_possible_positions_mod(map, start, SECOND_COUNT)

a, b, c = (
  Matrix.rows((0..2).map { [_1 ** 2, _1, 1] }).inverse *
  Vector.elements(ys)
).to_a.map!(&:to_i)

x = SECOND_COUNT / map.size

p a * (x ** 2) + b * x + c
