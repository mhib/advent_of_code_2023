Card = Struct.new(:char) do
  ORDERS = {
    **('2'..'9').map { [_1, _1.to_i] }.to_h,
    **%w[T J Q K A].map.with_index { [_1, _2 + 1000] }.to_h,
    **{ 'J' => -100 }
  }

  include Comparable

  def <=>(other)
    order - other.order
  end

  protected def order
    @order ||= ORDERS[char]
  end
end

class Play
  include Comparable

  JOKER = Card.new('J')

  attr_reader :bid
  def initialize(cards, bid)
    @cards = cards.each_char.map { Card.new(_1) }
    @bid = bid
  end

  def type
    @type ||= calculate_type
  end

  def <=>(other)
    order <=> other.order
  end

  protected def order
    @order ||= [type, @cards]
  end

  private

  def calculate_type
    jokers = @cards.count(JOKER)
    tally = @cards.reject { |c| c == JOKER }.tally

    return 6 if tally.empty?

    sorted = tally.values.tap(&:sort!)
    sorted[-1] += jokers
    return 6 if sorted.last == 5
    return 5 if sorted.last == 4
    return 4 if sorted.last == 3 && sorted[-2] == 2
    return 3 if sorted.last == 3
    return 2 if sorted.last == 2 && sorted[-2] == 2
    return 1 if sorted.last == 2
    0
  end
end

@plays = File.readlines('in.txt', chomp: true).map do |line|
  cards, bid = line.split(' ')
  Play.new(cards, bid.to_i)
end

@plays.sort!
@sum = 0

@plays.each_with_index do |el, idx|
  @sum += el.bid * (idx + 1)
end

p @sum