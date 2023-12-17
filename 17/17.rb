require 'pairing_heap'

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

def apply_move(pos, move)
  delta = MOVE_DELTAS[move]
  [
    pos[0] + delta[0],
    pos[1] + delta[1]
  ]
end

State = Struct.new(:pos, :direction, :count)

def find_shortest(map)
  heap = PairingHeap::SimplePairingHeap.new
  dist = {}

  length = map.size
  width = map[0].size

  is_pos_valid = lambda do |pos|
    pos[0] >= 0 && pos[0] < length && pos[1] >= 0 && pos[1] < width
  end

  destination =  [length - 1, width - 1]
  visited_destination = 0

  right = State.new([0, 1], RIGHT, 1)
  down = State.new([1, 0], DOWN, 1)
  dist[right] = map[0][1]
  dist[down] = map[1][0]

  heap.push(right, map[0][1])
  heap.push(down, map[1][0])

  while heap.any?
    state, d = heap.pop_with_priority
    next if dist[state] != d

    if state.pos == destination
      return d
    end

    new_dirs = if (state.direction == LEFT || state.direction == RIGHT)
                [UP, DOWN]
               else
                [LEFT, RIGHT]
               end
    new_dirs.each do |dir|
      new_pos = apply_move(state.pos, dir)
      next unless is_pos_valid[new_pos]
      new_state = State.new(new_pos, dir, 1)
      prev_d = dist[new_state]
      new_d = d + map[new_pos[0]][new_pos[1]]
      if prev_d.nil? || prev_d > new_d
        dist[new_state] = new_d
        heap.push(new_state, new_d)
      end
    end

    if state.count != 3
      new_pos = apply_move(state.pos, state.direction)
      next unless is_pos_valid[new_pos]
      new_state = State.new(new_pos, state.direction, state.count + 1)
      prev_d = dist[new_state]
      new_d = d + map[new_pos[0]][new_pos[1]]
      if prev_d.nil? || prev_d > new_d
        dist[new_state] = new_d
        heap.push(new_state, new_d)
      end
    end
  end

end

class Dist
  def initialize(length, width, max_moves)
    @arr = Array.new(4) { Array.new(max_moves) { Array.new(length) { Array.new(width) } } }
  end

  def [](state)
    @arr[state.direction][state.count][state.pos[0]][state.pos[1]]
  end

  def []=(state, value)
    @arr[state.direction][state.count][state.pos[0]][state.pos[1]] = value
  end
end

def find_shortest_second(map)
  heap = PairingHeap::SimplePairingHeap.new

  length = map.size
  width = map[0].size

  dist = Dist.new(length, width, 11)

  is_pos_valid = lambda do |pos|
    pos[0] >= 0 && pos[0] < length && pos[1] >= 0 && pos[1] < width
  end

  destination =  [length - 1, width - 1]
  visited_destination = 0

  right = State.new([0, 1], RIGHT, 1)
  down = State.new([1, 0], DOWN, 1)

  dist[right] = map[0][1]
  dist[down] = map[1][0]

  heap.push(right, map[0][1])
  heap.push(down, map[1][0])

  while heap.any?
    state, d = heap.pop_with_priority

    next if d != dist[state]

    if state.pos == destination && state.count >= 4
      return d
    end

    if state.count >= 4
      new_dirs = if (state.direction == LEFT || state.direction == RIGHT)
                  [UP, DOWN]
                else
                  [LEFT, RIGHT]
                end
      new_dirs.each do |dir|
        new_pos = apply_move(state.pos, dir)
        next unless is_pos_valid[new_pos]
        new_state = State.new(new_pos, dir, 1)

        prev_d = dist[new_state]
        new_d = d + map[new_pos[0]][new_pos[1]]
        if prev_d.nil? || prev_d > new_d
          heap.push(new_state, new_d)
          dist[new_state] = new_d
        end
      end
    end

    if state.count < 10
      new_pos = apply_move(state.pos, state.direction)
      next unless is_pos_valid[new_pos]
      new_state = State.new(new_pos, state.direction, state.count + 1)
      prev_d = dist[new_state]
      new_d = d + map[new_pos[0]][new_pos[1]]
      if prev_d.nil? || prev_d > new_d
        heap.push(new_state, new_d)
        dist[new_state] = new_d
      end
    end
  end

end

@map = File.readlines('in.txt', chomp: true).map { _1.each_char.map(&:to_i) }

p find_shortest_second(@map)