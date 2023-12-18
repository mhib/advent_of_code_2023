require 'set'

UP = 0
RIGHT = 1
DOWN = 2
LEFT = 3

DIR_DELTAS = [
  [-1, 0],
  [0, 1],
  [1, 0],
  [0, -1]
]

def apply_dir(pos, dir)
  delta = DIR_DELTAS[dir]
  [
    pos[0] + delta[0],
    pos[1] + delta[1]
  ]
end

def find_borders(plan)
  pos = [0, 0]
  idx = 0
  borders = Set.new([pos])
  plan.each do |dir, count, _|
    count.times do
      pos = apply_dir(pos, dir)
      borders << pos
    end
  end
  borders
end

def flood(borders)
  start_y, stop_y = borders.map(&:first).minmax
  start_y -= 1
  stop_y += 1
  start_x, stop_x = borders.map(&:last).minmax
  start_x -= 1
  stop_x += 1

  is_valid_pos = lambda do |pos|
    pos[0] >= start_y && pos[0] <= stop_y && pos[1] >= start_x && pos[1] <= stop_x
  end

  stack = [[start_y, 0]]
  visited = Set.new(stack)
  while stack.any?
    pos = stack.pop

    DIR_DELTAS.each_index do |dir|
      new_pos = apply_dir(pos, dir)
      next unless is_valid_pos[new_pos]
      next if borders.include?(new_pos)
      next unless visited.add?(new_pos)
      stack << new_pos
    end
  end

  (stop_y - start_y + 1) * (stop_x - start_x + 1) - visited.size
end

CHAR_TO_DIR = {
  'U' => UP,
  'R' => RIGHT,
  'D' => DOWN,
  'L' => LEFT,
}

COLOR_TO_DIR = [
  RIGHT, DOWN, LEFT, UP
]

part_1 = []
part_2 = []

File.readlines('in.txt', chomp: true).each do |line|
  dir, count, color = line.split(' ')
  part_1 << [CHAR_TO_DIR[dir], count.to_i, color]
  _, _, color = line.split(' ')
  count = color[2, 5].to_i(16)
  new_dir = COLOR_TO_DIR[color[7].to_i]
  part_2 << [new_dir, count]
end

# p flood(find_borders(plan))

def shoelace(l, r)
  l[0] * r[1] - l[1] * r[0]
end

def area(points)
  points = points + [points.first]
  points.each_cons(2).sum{ |p1,p2| shoelace(p1, p2) }.abs / 2
end

def find_points(plan)
  pos = [0, 0]
  points = []
  outside = 0
  plan.each do |dir, count|
    new_delta = DIR_DELTAS[dir].map { |x| x * count }
    pos = [
      pos[0] + new_delta[0],
      pos[1] + new_delta[1],
    ]

    points << pos
    outside += count
  end

  [points, outside]
end

[part_1, part_2].each do |plan|
  points, outside = find_points(plan)

  # https://en.wikipedia.org/wiki/Pick%27s_theorem
  # area = inside + (outside / 2) - 1
  # area + 1 = inside + (outside / 2)
  # inside + outside = area + (outside / 2) + 1
  p area(points) + (outside / 2) + 1
end


