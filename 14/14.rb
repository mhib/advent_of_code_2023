def move_column_sum(rows, x)
  max_move = 0
  len = rows.size

  sum = 0

  rows.each_with_index do |row, y|
    el = row[x]
    if el == '#'
      max_move = y + 1
      next
    end

    if el == 'O'
      sum += len - max_move
      max_move += 1
    end
  end

  sum
end

def each_column(rows, &block)
  rows[0].each_index(&block)
end

def each_row(rows, &block)
  rows.each_index(&block)
end

def move_column_north!(rows, x)
  max_move = 0
  rows.each_index do |y|
    el = rows[y][x]
    if el == '#'
      max_move = y + 1
      next
    end

    if el == 'O'
      rows[y][x], rows[max_move][x] = rows[max_move][x], rows[y][x]
      max_move += 1
    end
  end
end

def move_column_south!(rows, x)
  max_move = rows.size - 1

  (rows.size - 1).downto(0) do |y|
    el = rows[y][x]
    if el == '#'
      max_move = y - 1
      next
    end

    if el == 'O'
      rows[y][x], rows[max_move][x] = rows[max_move][x], rows[y][x]
      max_move -= 1
    end
  end
end

def move_row_west!(rows, y)
  max_move = 0

  rows[0].each_index do |x|
    el = rows[y][x]
    if el == '#'
      max_move = x + 1
      next
    end

    if el == 'O'
      rows[y][x], rows[y][max_move] = rows[y][max_move], rows[y][x]
      max_move += 1
    end
  end
end

def move_row_east!(rows, y)
  max_move = rows[0].size - 1

  (rows[0].size - 1).downto(0) do |x|
    el = rows[y][x]
    if el == '#'
      max_move = x - 1
      next
    end

    if el == 'O'
      rows[y][x], rows[y][max_move] = rows[y][max_move], rows[y][x]
      max_move -= 1
    end
  end
end

def do_cycle!(rows)
  each_column(rows) { move_column_north!(rows, _1) }
  each_row(rows) { move_row_west!(rows, _1) }
  each_column(rows) { move_column_south!(rows, _1) }
  each_row(rows) { move_row_east!(rows, _1) }
end

def find_cycle(rows)
  tail = nil
  visited = {}
  i = 0
  visited[rows.map(&:dup)] = i
  loop do
    i += 1
    do_cycle!(rows)

    if prev = visited[rows]
      return [prev, i - prev, visited.keys]
    end
    visited[rows.map(&:dup)] = i
  end
end

def calculate_column_cost(rows, x)
  len = rows.size
  sum = 0
  0.upto(rows.size - 1) do |y|
    if rows[y][x] == 'O'
      sum += len - y
    end
  end
  sum
end

def calculate_cost(rows)
  each_column(rows).reduce(0) { _1 + calculate_column_cost(rows, _2) }
end


@rows = File.readlines('in.txt', chomp: true).map(&:chars)

tail, cycle_size, visited = find_cycle(@rows)
p [tail, cycle_size]

ROTATIONS = 1_000_000_000
rotations_to_do = tail + ((ROTATIONS - tail) % cycle_size)

p calculate_cost(visited[rotations_to_do])