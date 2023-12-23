require 'set'
map = File.readlines('in.txt', chomp: true).to_a

NEIS = [
  [-1, 0],
  [1, 0],
  [0, -1],
  [0, 1]
]

def get_neis(char)
  case char
  when '.'
    NEIS
  when '#'
    []
  when '<'
    [[0, -1]]
  when '>'
    [[0, 1]]
  when 'v'
    [[1, 0]]
  else
    [[-1, 0]]
  end
end

def find_longest_path_1(map)
  length = map.size
  width = map[0].size
  start = [0, 1]
  destination = [length - 1, width - 2]

  max_length = 0

  dfs = lambda do |current, visited|
    if current == destination
      max_length = [visited.size - 1, max_length].max
      return
    end
    y, x = current
    cell = map[y][x]
    get_neis(cell).each do |delta_y, delta_x|
      new_y = y + delta_y
      next if new_y < 0
      new_x = x + delta_x
      new_pos = [new_y, new_x]
      next unless visited.add?(new_pos)
      dfs.(new_pos, visited)
      visited.delete(new_pos)
    end
  end


  dfs.(start, Set[start])

  max_length
end

def find_compressed_path(map, prev, deltas)
  length = map.size
  width = map[0].size
  south_end = [length - 1, width - 2]

  start = [prev[0] + deltas[0], prev[1] + deltas[1]]

  return nil if start[0] <= 0 || start[0] >= length
  return nil if map[start[0]][start[1]] == '#'
  return [south_end, 1] if start == south_end

  visited = Set[prev, start]
  current = start

  while true
    new_current = nil
    y, x = current
    NEIS.each do |delta_y, delta_x|
      new_y = y + delta_y
      next if new_y <= 0
      new_x = x + delta_x
      next if map[new_y][new_x] == '#'
      tmp = [new_y, new_x]
      next if visited.include?(tmp)
      if new_current
        return [current, visited.size - 1]
      end
      new_current = tmp
    end
    return nil unless new_current
    if new_current == south_end
      return [new_current, visited.size]
    end
    visited << new_current
    current = new_current
  end
end

def find_longest_path_compressed(map, compressed_paths)
  length = map.size
  width = map[0].size
  start = [0, 1]
  destination = [length - 1, width - 2]

  visited = Array.new(width * length, false)

  to_id = lambda do |(y, x)|
    y * width + x
  end

  max_length = 0

  dfs = lambda do |current, len|
    if current == destination
      if len > max_length
        max_length = len
        puts "Best so far: #{max_length}"
      end
      return
    end
    y, x = current
    compressed_paths[y][x].each do |nei|
      id = to_id[nei[0]]
      next if visited[id]
      visited[id] = true
      dfs.(nei[0], len + nei[1])
      visited[id] = false
    end
  end


  visited[to_id[start]] = true
  dfs.(start, 0)

  max_length
end


# part 2 with very simple ad-hoc compression
def find_longest_path_2(map)
  length = map.size
  width = map[0].size
  start = [0, 1]
  destination = [length - 1, width - 2]

  max_length = 0

  dfs = lambda do |current, visited, len|
    if current == destination
      if len > max_length
        max_length = len
        p max_length
      end
      return
    end
    y, x = current
    cell = map[y][x]
    (cell == '#' ? [] : NEIS).each do |delta_y, delta_x|
      new_y = y
      new_x = x
      if delta_y != 0
        while true
          new_y += delta_y
          break if new_y < 0
          if new_y >= length
            new_y -= delta_y
            break
          end
          if map[new_y][new_x] == '#'
            new_y -= delta_y
            break
          end
          break unless map[new_y][new_x - 1] == '#' && map[new_y][new_x + 1] == '#'
        end
      else
        while true
          new_x += delta_x
          if map[new_y][new_x] == '#'
            new_x -= delta_x
            break
          end
          break unless map[new_y - 1][new_x] == '#' && map[new_y + 1][new_x] == '#'
        end
      end
      next if map[new_y][new_x] == '#'
      new_pos = [new_y, new_x]
      next unless visited.add?(new_pos)
      dfs.(new_pos, visited, len + [(new_y - y).abs, (new_x - x).abs].max)
      visited.delete(new_pos)
    end
  end

  dfs.(start, Set[start], 0)

  max_length
end

compressed = map.map.with_index do |row, y|
  row.each_char.map.with_index do |c, x|
    next [] if c == "#"

    NEIS.map do |i|
      find_compressed_path(map, [y, x], i)
    end.tap(&:compact!)
  end
end

p find_longest_path_1(map)
p find_longest_path_compressed(map, compressed)