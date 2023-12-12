def count_possibilities(line, counts)
  mem = Array.new(line.size) { Array.new(counts.size) }
  last_required = line.chars.rindex('#') || -1
  aux = lambda do |start, counts_idx|
    if counts_idx >= counts.size
      return 0 if start <= last_required
      return 1
    end
    return 0 if start >= line.size
    
    if val = mem[start][counts_idx]
      return val
    end
    
    count_needed = counts[counts_idx]

    count_matched = true
    start.upto(start + count_needed - 1) do |line_i|
      char = line[line_i]
      unless char == '#' || char == '?'
        count_matched = false
        break
      end
    end
    
    sum = 0
    
    if line[start] != '#'
      sum += aux.(start + 1, counts_idx)
    end
    if count_matched && line[start + count_needed] != '#'
      sum += aux.(start + count_needed + 1, counts_idx + 1)
    end
    
    mem[start][counts_idx] = sum
  end
  
  aux.(0, 0)
end

sum = 0
File.readlines('in.txt', chomp: true).each do |line|
  registry, counts = line.split(' ')
  registry = 5.times.map { registry }.join("?")
  counts = counts.split(',').map(&:to_i) * 5
  x = count_possibilities(registry, counts)
  # p [registry, counts, x]
  sum += x
end
p sum