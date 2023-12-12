require 'set'
@map = File.readlines('in.txt', chomp: true).map.to_a

@rows_without_galaxy = Set.new(@map.each_index.to_a)
@columns_without_galaxy = Set.new(0.upto(@map[0].size - 1).to_a)

@galaxies = []

@map.each_with_index do |row, y|
  row.each_char.with_index do |cell, x|
    if cell == '#'
      @rows_without_galaxy.delete(y)
      @columns_without_galaxy.delete(x)
      @galaxies << [y, x]
    end
  end
end

acc = 0
@row_without_galaxies_count = @map.each_index.map do |y|
  if @rows_without_galaxy.include?(y)
    acc += 1
  end
  acc
end

acc = 0
@column_without_galaxies_count = 0.upto(@map[0].size - 1).map do |x|
  if @columns_without_galaxy.include?(x)
    acc += 1
  end
  acc
end

sum = 0
0.upto(@galaxies.size - 2) do |left_i|
  left = @galaxies[left_i]
  (left_i + 1).upto(@galaxies.size - 1) do |right_i|
    right = @galaxies[right_i]
    ys = [left[0], right[0]].sort
    sum += ys[1] - ys[0]
    sum += (@row_without_galaxies_count[ys[1]] - @row_without_galaxies_count[ys[0]]) * (1000000 - 1)

    xs = [left[1], right[1]].sort
    sum += xs[1] - xs[0]
    sum += (@column_without_galaxies_count[xs[1]] - @column_without_galaxies_count[xs[0]]) * (1000000 - 1)

  end
end
p sum