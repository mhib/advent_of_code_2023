POSSIBLE_NEIS = [
  [-1, 0],
  [0, -1],
  [0, 1],
  [1, 0]
]
NEIS = {
  '|' => [[-1, 0], [1, 0]],
  '-' => [[0, -1], [0, 1]],
  'L' => [[-1, 0],  [0, 1]],
  'J' => [[-1, 0],  [0, -1]],
  '7' => [[1, 0], [0, -1]],
  'F' => [[1, 0], [0, 1]],
}


@start = nil

@map = File.readlines('in.txt', chomp: true).map.with_index do |l, y|
  if (i = l.index('S'))
    @start = [y, i]
  end
  
  l
end

@width = @map[0].size
@length = @map.size

def get_neis(y, x)
  pipe = @map[y][x]
  
  NEIS[pipe].map do |delta_y, delta_x|
    new_y = y + delta_y
    next if new_y >= @length || new_y < 0
    new_x = x + delta_x
    next if new_x >= @width || new_x < 0

    [new_y, new_x]
  end.compact
end

def get_possible_neis(y, x)
  POSSIBLE_NEIS.map do |delta_y, delta_x|
    new_y = y + delta_y
    next if new_y >= @length || new_y < 0
    new_x = x + delta_x
    next if new_x >= @width || new_x < 0

    [new_y, new_x]
  end.compact
end

def replace_s!

  neis = []

  y, x = @start

  POSSIBLE_NEIS.each do |delta_y, delta_x|
    new_y = y + delta_y
    new_x = x + delta_x
    next if new_y >= @length || new_y < 0
    next if new_x >= @width || new_x < 0
    
    pipe = @map[new_y][new_x]
    next if pipe == '.'
    
    is_nei = get_neis(new_y, new_x).include?([y, x])
    
    if is_nei
      neis << [new_y, new_x]
    end
  end

  neis.sort!

  NEIS.each_key do |char|
    @map[y][x] = char
    candidates = get_neis(y, x)
    break if candidates.sort == neis
  end
end


def find_furthest(y, x)
  dist = -1
  
  q = [[y, x]]
  
  # visited = Array.new(@length) { Array.new(@width, false) }
  # visited[y][x] = true
  visited = Set.new(q)
  
  while q.any?
    q.size.times do
      y, x = q.shift
      get_neis(y, x).each do |to_y, to_x|
        next if visited.include?([to_y, to_x])
        next unless get_neis(to_y, to_x).include?([y, x])
        q << [to_y, to_x]
        visited << [to_y, to_x]
      end
    end
    dist += 1
  end
  [dist, visited]
end

def find_inner(border)
  count = 0
  @map.each_with_index do |row, y|
    inside = 0
    row.each_char.with_index do |c, x|
      if !border.include?([y, x])
        count += inside
      elsif %w[| L J].include?(c)
        inside ^= 1
      end
    end
  end
  count
end

replace_s!
length, border = find_furthest(*@start)
p length

p find_inner(border)

