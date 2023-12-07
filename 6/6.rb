@times, @records = File.readlines('in.txt', chomp: true).map do |line|
  _, line = line.split(':')
  line.split(' ').map(&:to_i)
end

def check_valid(x, t, r)
  x * (t - x) > r
end

def get_ways(t, r)
  delta = (t * t - 4 * r)**0.5
  min = (t - delta) / 2
  max = (t + delta) / 2

  sum = max.floor - min.ceil + 1

  sum -= 1 unless check_valid(min.ceil, t, r)

  sum -= 1 unless check_valid(max.floor, t, r)

  sum
end

val = @times.zip(@records).map do |t, r|
  get_ways(t, r)
end.reduce(&:*)

p val

def nums_to_one(arr)
  arr.map(&:to_s).join('').to_i
end

val = get_ways(nums_to_one(@times), nums_to_one(@records))

p val