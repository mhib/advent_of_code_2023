require 'z3'

def det(a, b)
  a[0] * b[1] - a[1] * b[0]
end

def line_intersection(line1, line2)
  xdiff = [line1[0][0] - line1[1][0], line2[0][0] - line2[1][0]]
  ydiff = [line1[0][1] - line1[1][1], line2[0][1] - line2[1][1]]


  div = det(xdiff, ydiff)
  return nil if div == 0

  d = [det(*line1), det(*line2)]
  x = det(d, xdiff) / div
  y = det(d, ydiff) / div
  [x, y]
end

Hail = Struct.new(:point, :vector) do
  def line
    [
      [point[0], point[1]],
      [point[0] + vector[0], point[1] + vector[1]]
    ]
  end
end

hails = File.readlines('in.txt', chomp: true).map do |line|
  point_and_vector = line.split(" @ ")
  Hail.new(
    *point_and_vector.map do |v|
      v.split(", ").map(&:to_i)
    end
  )

end

def part1(hails)
  range = 200000000000000..400000000000000
  count = 0
  0.upto(hails.size - 2) do |left_i|
    left = hails[left_i]
    left_line = left.line.map { _1.map(&:to_r) }
    (left_i + 1).upto(hails.size - 1) do |i|
      right = hails[i]
      right_line = right.line.map { _1.map(&:to_r) }
      intersection = line_intersection(left_line, right_line)
      next unless intersection
      next unless intersection.all? { range.cover?(_1) }

      # this works as there are no 0 in vectors, if there were we would've to check also y
      if [left, right].all? { (intersection[0] <=> _1.point[0]) == (_1.vector[0] <=> 0) }
        count += 1
      end
    end
  end
  count
end

p part1(hails)

def part2(hails)
  solver = Z3::Solver.new
  px = Z3.Int("px")
  py = Z3.Int("py")
  pz = Z3.Int("pz")

  vx = Z3.Int("vx")
  vy = Z3.Int("vy")
  vz = Z3.Int("vz")
  hails.each_with_index do |h, i|
    t = Z3.Int("t_#{i}")
    solver.assert t >= 0
    solver.assert px + vx * t == t * h.vector[0] + h.point[0]
    solver.assert py + vy * t == t * h.vector[1] + h.point[1]
    solver.assert pz + vz * t == t * h.vector[2] + h.point[2]
  end

  solver.check

  model = solver.model

  [px, py, pz].map { model[_1].to_i}.sum
end


p part2(hails)