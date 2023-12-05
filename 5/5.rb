@seeds = []
Mapping = Struct.new(:destination, :start, :length) do
  def range
    @range ||= (start..right)
  end

  def right
    start + length - 1
  end

  def cover?(value)
    range.cover?(value)
  end
end

@mappings = []

@seed_parsed = false

DIGITS = ('0'..'9')

File.readlines('in.txt', chomp: true).each do |line|
  unless @seed_parsed
    _, line = line.split('seeds:')
    @seeds = line.split(' ').map(&:to_i)
    @seed_parsed = true
    next
  end

  next if line.empty?

  unless DIGITS.cover?(line[0])
    @mappings << []
    next
  end

  @mappings.last << Mapping.new(*line.split(' ').map(&:to_i))
end

@mappings.each { _1.sort_by!(&:start) }

def traverse(current)
  @mappings.each do |m|
    candidate_idx = m.bsearch_index { |x| x.start > current } || m.size
    candidate_idx -= 1
    next if candidate_idx.negative?
    candidate = m[candidate_idx]
    next unless candidate.cover?(current)
    current = candidate.destination + (current - candidate.start)
  end
  current
end

def traverse_range(left, right, i)
  return left if i >= @mappings.size

  mapping = @mappings[i]

  candidate_idx = mapping.bsearch_index { |x| x.right >= left }

  if candidate_idx.nil?
    return traverse_range(left, right, i + 1)
  end

  min = 1.0 / 0
  current_left = left

  while candidate_idx < mapping.size && current_left <= right
    candidate = mapping[candidate_idx]

    # We do not match any more
    if candidate.start > right
      min = [traverse_range(current_left, right, i + 1), min].min
      break
    end

    # candidate matches our right side
    # so we do identity mapping for our left side
    if candidate.start > current_left
      min = [traverse_range(current_left, [right, candidate.start - 1].min, i + 1), min].min
      current_left = candidate.start
    end

    # candidate matches our left side
    if candidate.right >= current_left
      start = candidate.destination + (current_left - candidate.start)
      old_stop = [candidate.right, right].min
      new_stop = candidate.destination + (old_stop - candidate.start)
      min = [traverse_range(start, new_stop, i + 1), min].min
      current_left = old_stop + 1
    end

    candidate_idx += 1
  end
  min
end


p @seeds.map { traverse(_1) }.min

p @seeds.each_slice(2).map { traverse_range(_1[0], _1.sum, 0) }.min
