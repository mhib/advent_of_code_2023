UP = 0
RIGHT = 1
DOWN = 2
LEFT = 3

MOVE_DELTAS = [
  [-1, 0],
  [0, 1],
  [1, 0],
  [0, -1]
]

def apply_move(pos, direction)
  delta = MOVE_DELTAS[direction]

  [
    pos[0] + delta[0],
    pos[1] + delta[1]
  ]
end

def visit(map, pos, direction)
  length = map.size
  width = map[0].size

  is_pos_valid = lambda do |new_pos|
    new_pos[0] >= 0 && new_pos[0] < length && new_pos[1] >= 0 && new_pos[1] < width
  end

  start = [pos, direction]
  stack = [start]
  visited = Set.new(stack)

  while stack.any?
    pos, direction = stack.pop
    char = map[pos[0]][pos[1]]

    if ((direction == UP || direction == DOWN) && char == '|') ||
        ((direction == LEFT || direction == RIGHT) && char == '-')
      char = '.'
    end

    if char == '|'
      [UP, DOWN].each do |new_direction|
        new_pos = apply_move(pos, new_direction)
        next unless is_pos_valid.(new_pos)
        next unless visited.add?([new_pos, new_direction])
        stack << [new_pos, new_direction]
      end
      next
    end

    if char == '-'
      [LEFT, RIGHT].each do |new_direction|
        new_pos = apply_move(pos, new_direction)
        next unless is_pos_valid.(new_pos)
        next unless visited.add?([new_pos, new_direction])
        stack << [new_pos, new_direction]
      end
      next
    end

    if char == '.'
      new_direction = direction
    elsif char == '/'
      new_direction = case direction
                      when LEFT
                        DOWN
                      when UP
                        RIGHT
                      when RIGHT
                        UP
                      else
                        LEFT
                      end
    else # == '\\'
      new_direction = case direction
                      when LEFT
                        UP
                      when UP
                        LEFT
                      when RIGHT
                        DOWN
                      else
                        RIGHT
                      end
    end

    new_pos = apply_move(pos, new_direction)
    next unless is_pos_valid.(new_pos)
    next unless visited.add?([new_pos, new_direction])
    stack << [new_pos, new_direction]
  end

  visited.map(&:first).tap(&:uniq!).size
end

@map = File.readlines('in.txt', chomp: true).to_a

max = -1
length = @map.size
width = @map[0].size

0.upto(length - 1) do |row|
  max = [
    visit(@map, [row, 0], RIGHT),
    visit(@map, [row, width - 1], LEFT),
    max
  ].max
end

0.upto(width - 1) do |column|
  max = [
    visit(@map, [0, column], DOWN),
    visit(@map, [length - 1,  column], UP),
    max
  ].max
end

p max