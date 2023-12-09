require 'set'
@nodes = {}

@moves = nil
REGEX = /(\w{3}) = \((\w{3}), (\w{3})\)/

File.readlines('in.txt', chomp: true).each do |line|
  unless @moves
    @moves = line
    next
  end

  next if line.empty?

  node, left, right = line.scan(REGEX)[0]
  @nodes[node] = [left, right]

end

# move_count = 0
# current = 'AAA'

# while true
#   move = @moves[move_count % @moves.size] == 'L' ? 0 : 1
#   move_count += 1

#   current = @nodes[current][move]
#   break if current == 'ZZZ'
# end

# p move_count

def find_cycle(node)
  move_count = 0

  until node.end_with?('Z')
    move = @moves[move_count % @moves.size] == 'L' ? 0 : 1
    move_count += 1
    node = @nodes[node][move]
  end

  move_count
end

p @nodes.each_key.select { _1.end_with?('A') }.map { find_cycle(_1) }.reduce(&:lcm)

