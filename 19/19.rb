# frozen_string_literal: true

LABELS = %w[x m a s].freeze

class Matcher
  attr_reader :result, :variable, :operator, :value
  def initialize(variable, operator, value, result)
    @variable = variable
    @operator = operator
    @value = value
    @result = result
  end

  def matches?(part)
    part[@variable].send(@operator, @value)
  end
end

class Rule
  attr_reader :matchers
  attr_reader :otherwise
  def initialize(mathers, otherwise)
    @matchers = mathers
    @otherwise = otherwise
  end

  def interpret(part)
    found = @matchers.find do |m|
      m.matches?(part)
    end

    found&.result || @otherwise
  end
end

@rules = {}
@parts = []
state = :matches

File.readlines('in.txt', chomp: true).each do |line|
  if state == :matches
    if line.empty?
      state = :parts
      next
    end
    name, rules = line.split("{")
    rules = rules[0..-2]
    rules = rules.split(",")
    otherwise = rules.pop
    matchers = rules.map do |m|
      if m.include?('<')
        variable, rest = m.split('<')
        operator = '<'
      else
        variable, rest = m.split('>')
        operator = '>'
      end
      value, result = rest.split(':')
      Matcher.new(variable, operator, value.to_i, result)
    end
    @rules[name] = Rule.new(matchers, otherwise)
  else
    break if line.empty?
    @parts << LABELS.zip(line.scan(/(\d+)/).map(&:first).map(&:to_i)).to_h
  end
end

def interpret(part)
  current = @rules["in"]
  while true
    res = current.interpret(part)
    return true if res == 'A'
    return false if res == 'R'
    current = @rules[res]
  end
end

def all_combinations
  state = LABELS.map { [1, 4000] }
  valid = 0

  variable_to_idx = LABELS.map.with_index.to_h

  # ab meaning alpha-beta i.e. lower_bound, upper_bound
  visit = lambda do |current, abs|
    return if current == 'R'
    if current == 'A'
      valid += abs.reduce(1) { _1 * (_2.last - _2.first + 1) }
      return
    end
    rule = @rules[current]

    rule.matchers.each do |matcher|
      abi = variable_to_idx[matcher.variable]
      ab = abs[abi]
      if matcher.operator == '<' 
        next if ab[0] >= matcher.value
        if ab[1] < matcher.value
          visit.(matcher.result, abs)
          return
        end
        new_abs = abs.map(&:dup)
        new_abs[abi][1] = matcher.value - 1
        visit.(matcher.result, new_abs)
        abs[abi][0] = matcher.value
      else
        next if ab[1] <= matcher.value
        if ab[0] > matcher.value
          visit.(matcher.result, abs)
          return
        end
        new_abs = abs.map(&:dup)
        new_abs[abi][0] = matcher.value + 1
        visit.(matcher.result, new_abs)
        abs[abi][1] = matcher.value
      end
    end

    visit.(rule.otherwise, abs)
  end

  visit.('in', state)

  valid
end

p @parts.filter { interpret(_1) }.map { _1.values.sum }.sum
p all_combinations