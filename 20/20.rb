require 'set'
class Broadcaster
  attr_reader :egress, :name

  def initialize(name, egress)
    @name = name
    @egress = egress
    @signal = 0
  end

  def add_ingress!(_ignored)
  end

  def receive(signal, _source)
    @signal = signal
    true
  end

  def value
    @signal
  end
end

class FlipFlop
  attr_reader :egress, :name

  def initialize(name, egress)
    @name = name
    @egress = egress
    @state = 0
  end

  def receive(signal, _source)
    if signal.zero?
      @state ^= 1
      return true
    end
    false
  end

  def add_ingress!(_ignored)
  end

  def value
    @state
  end
end

class Conjuction
  attr_reader :egress, :ingress, :name
  def initialize(name, egress)
    @name = name
    @egress = egress
    @ingress = {}
    @mask = 0
    @full_mask = 0
  end

  def add_ingress!(name)
    @ingress[name] = ingress.size
    @full_mask = (1 << ingress.size) - 1
  end

  def receive(signal, source)
    of = (1 << @ingress[source])
    prev = (@mask & of) == 0 ? 0 : 1
    if prev == signal
      return true
    end
    @mask ^= of
    return true
  end

  def value
    @mask == @full_mask ? 0 : 1
  end

  private

  def get_in_value(source)
    @mask & (1 << @ingress[source]) == 0 ? 0 : 1
  end
end

@modules = {}

File.readlines('in.txt', chomp: true).each do |line|
  name, egress = line.split(" -> ")
  egress = egress.split(", ")
  if name.start_with?('%')
    name = name[1..-1]
    @modules[name] = FlipFlop.new(name, egress)
  elsif name.start_with?('&')
    name = name[1..-1]
    @modules[name] = Conjuction.new(name, egress)
  else
    @modules[name] = Broadcaster.new(name, egress)
  end
end

@modules.to_a.each do |k, v|
  v.egress.each do |n|
    @modules[n] ||= Broadcaster.new(n, [])
    @modules[n].add_ingress!(k)
  end
end

def push
  low = 0
  high = 0

  current = [@modules["broadcaster"]]
  low = 1

  while current.any?
    current.size.times do 
      el = current.shift
      value = el.value
      if value == 0
        low += el.egress.size
      else
        high += el.egress.size
      end
      el.egress.each do |eg|
        eg = @modules[eg]
        if eg.receive(value, el.name)
          current << eg
        end
      end
    end
  end
  [low, high]
end

def find_presses
  i = 1
  sender = @modules.select do |k, v|
    v.egress.include?('rx')
  end.map(&:first)[0]
  inputs = @modules.select do |k, v|
    v.egress.include?(sender)
  end.map(&:first).to_set
  input_counts = {}

  while true
    current = [@modules["broadcaster"]]

    while current.any?
      current.size.times do 
        el = current.shift
        value = el.value
        el.egress.each do |name|
          if value == 0 && inputs.include?(name) && !input_counts[name]
            input_counts[name] = i

            return input_counts.values.reduce(&:lcm) if input_counts.size == inputs.size
          end
          eg = @modules[name]
          if eg.receive(value, el.name)
            current << eg
          end
        end
      end
    end
    i += 1
  end
end

p find_presses