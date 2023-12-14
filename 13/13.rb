def find_horizontals(rec)
  all = []
  1.upto(rec.size - 1) do |horizontal_line|
    up = horizontal_line - 1
    down = horizontal_line
    found = true

    while up >= 0 && down < rec.size
      if rec[up] != rec[down]
        found = false
        break
      end
      up -= 1
      down += 1
    end
    all << horizontal_line if found
  end

  all
end

def find_verticals(rec)
  all = []
  1.upto(rec[0].size - 1) do |vertical_line|
    left = vertical_line - 1
    right = vertical_line

    found = true
    while left >= 0 && right < rec[0].size
      ok = 0.upto(rec.size - 1).all? do |y|
        rec[y][left] == rec[y][right]
      end
      unless ok
        found = false
        break
      end
      left -= 1
      right += 1
    end
    all << vertical_line if found
  end
  all
end

def find_symmetric(rec)
  hor = find_horizontals(rec)
  ver = find_verticals(rec)


  hor.sum * 100 + ver.sum
end

def calc_diff(l, r)
  l.find { !r.include?(_1) }
end

def find_with_smudge(rec)
  prev_horizontal = Set.new(find_horizontals(rec))
  prev_vertical = Set.new(find_verticals(rec))
  rec.each_with_index do |row, y|
    row.each_char.with_index do |cell, x|
      if cell == '.'
        rec[y][x] = '#'
      else
        rec[y][x] = '.'
      end

      diff = calc_diff(find_horizontals(rec), prev_horizontal)
      if diff
        return diff * 100
      end

      diff = calc_diff(find_verticals(rec), prev_vertical)
      if diff
        return diff
      end

      rec[y][x] = cell
    end
  end
end

sum = 0
current_rec = []
File.readlines('in.txt', chomp: true).each do |line|
  if line.empty?
    sum += find_with_smudge(current_rec)
    current_rec = []
  else
    current_rec << line
  end
end
sum += find_with_smudge(current_rec)

p sum