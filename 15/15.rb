
@input = File.readlines('in.txt', chomp: true)[0].split(",")

def calculate_hash(input)
  current = 0
  input.each_char do |c|
    current += c.ord
    current *= 17
    current &= 255
  end
  current
end

class Facility
  def initialize
    @boxes = Array.new(256) { Hash.new }
  end

  def interpret(command)
    if command.end_with?("-")
      name = command[0...-1]
      name_box(name).delete(name)
      return
    end

    name, value = command.split('=')
    name_box(name)[name] = value.to_i
  end

  def sum_focusing_powers
    sum = 0
    @boxes.each_with_index do |box, y|
      i = 1
      box.each do |name, len|
        sum += (y + 1) * i * len

        i += 1
      end
    end
    sum
  end

  private

  def name_box(name)
    @boxes[calculate_hash(name)]
  end
end

facility = Facility.new

@input.each { facility.interpret(_1) }

p facility.sum_focusing_powers