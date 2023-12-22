require 'set'

Cube = Struct.new(:id, :first, :second) do
  def x_range
    [first, second].map(&:first).sort!
  end

  def y_range
    [first, second].map { _1[1] }.sort!
  end

  def collide?(other)
    directly_above = second.last == other.first.last - 1
    return false unless directly_above
    x1s, x1e = x_range
    y1s, y1e = y_range

    x2s, x2e = other.x_range
    y2s, y2e = other.y_range

    x_collision = x1s <= x2e && x2s <= x1e
    y_collision = y1s <= y2e && y2s <= y1e

    y_collision && x_collision
  end

  def down!
    first[-1] -= 1
    second[-1] -= 1
  end

  def dup
    Cube.new(
      id, first.dup, second.dup
    )
  end
end

cubes = File.readlines('in.txt', chomp: true).map.with_index do |line, i|
  points = line.split("~")
  points.map! { _1.split(",").map!(&:to_i) }
  if points[0].last > points[1].last
    points[0], points[1] = points[1], points[0]
  end
  Cube.new(i, *points)
end



def simulate_down(cubes)
  already_fallen, to_simulate = cubes.partition { _1.first.last == 1 }
  to_simulate.sort_by! { _1.first.last }

  not_supporting = Set.new(cubes.map(&:id))

  while to_simulate.any?
    new_to_simulate = []
    to_simulate.each do |current|

      if current.first[-1] == 1
        already_fallen << current
        next
      end
      all_collided = already_fallen.select { _1.collide?(current) }
      if all_collided.any?
        already_fallen << current
        if all_collided.size == 1
          collided = all_collided.first
          not_supporting.delete(collided.id)
        end
        next
      else
        new_to_simulate << current
      end

      current.down!
    end
    to_simulate = new_to_simulate
  end
  not_supporting
end

def with_children_and_parents(cubes)
  already_fallen, to_simulate = cubes.partition { _1.first.last == 1 }
  to_simulate.sort_by! { _1.first.last }

  parents = Array.new(cubes.size, 0)
  children = Array.new(cubes.size) { [] }

  while to_simulate.any?
    new_to_simulate = []
    to_simulate.each do |current|

      if current.first[-1] == 1
        already_fallen << current
        next
      end
      ps = already_fallen.filter { _1.collide?(current) }
      if ps.any?
        parents[current.id] = ps.size
        ps.each { |p| children[p.id] << current.id }
        already_fallen << current
        next
      else
        new_to_simulate << current
      end

      current.down!
    end
    to_simulate = new_to_simulate
  end
  cubes
  [parents, children]
end

def find_changed(cubes)
  parents, children = with_children_and_parents(cubes)

  count_for_brick = lambda do |id|
    count = 0
    i_parents = parents.dup

    q = [id]
    while q.any?
      current = q.shift

      children[current].each do |c|
        i_parents[c] -= 1
        if i_parents[c] == 0
          count += 1
          q << c
        end
      end
    end
    count
  end

  cubes.each_index.sum(&count_for_brick)
end

# naive part 2; it is tbh good enough
# def just_simulate(cubes)
#   already_fallen, to_simulate = cubes.partition { _1.first.last == 1 }
#   to_simulate.sort_by! { _1.first.last }

#   while to_simulate.any?
#     new_to_simulate = []
#     to_simulate.each do |current|

#       if current.first[-1] == 1
#         already_fallen << current
#         next
#       end
#       if already_fallen.any? { _1.collide?(current) }
#         already_fallen << current
#         next
#       else
#         new_to_simulate << current
#       end

#       current.first[-1] -= 1
#       current.second[-1] -= 1
#     end
#     to_simulate = new_to_simulate
#   end
#   cubes
# end
#
# def find_changed(cubes)
#   raw_result = just_simulate(cubes.map(&:dup))

#   count = 0

#   Parallel.map(cubes.each_with_index, in_processes: 8) do |cube, i|
#     count = 0
#     tmp_cubes = []
#     cubes.each_with_index do |e, inner|
#       next if inner == i
#       tmp_cubes << e.dup
#     end
#     without = just_simulate(tmp_cubes)
#     without.each do |c|
#       count += 1 if c != raw_result[c.id]
#     end
#     count
#   end.sum
# end

p simulate_down(cubes.map(&:dup)).size
p find_changed(cubes.map(&:dup))

# p find_changed(cubes.map(&:dup))