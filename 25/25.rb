
require 'set'
node_edges = Hash.new { |h, k| h[k] = [] }
edges = []

File.readlines('in.txt', chomp: true).each do |line|
  parent, children = line.split(": ")
  children.split(" ").each do |el|
    node_edges[parent] << edges.size
    node_edges[el] << edges.size
    edges << [parent, el]
  end
end

class UnionFind
  attr_reader :count
  def initialize(nodes)
    @sizes = Array.new(nodes, 1)
    @sets = (0...nodes).to_a
    @count = nodes
  end

  def find(x)
    if @sets[x] != x
      @sets[x] = find(@sets[x])
    end
    @sets[x]
  end

  def union(l, r)
    l = find(l)
    r = find(r)

    return if l == r
    @count -= 1
    l, r = r, l if @sizes[l] < @sizes[r]
    @sets[r] = l
    @sizes[l] += @sizes[r]
  end

  def set_sizes
    s = Set.new

    @sets.each_index do |k|
      s << find(k)
      break if s.size >= @count
    end
    s.map { @sizes[_1] }
  end

  def dup
    dup = UnionFind.allocate
    dup.count = count
    dup.sizes = @sizes.dup
    dup.sets = @sets.dup
    dup
  end

  protected

  attr_writer :count, :sizes, :sets
end

def karger(node_edges, edges)
  node_to_idx = node_edges.keys.map.with_index.to_h
  edges = edges.map do |nodes|
    nodes.map(&node_to_idx)
  end
  while true
    uf = UnionFind.new(node_to_idx.size)
    edges.shuffle!
    i = 0
    edges.each do |l, r|
      i += 1
      uf.union(l, r)
      break if uf.count == 2
    end
    edge_count = 0
    i.upto(edges.size - 1) do |x|
      l, r = edges[x]
      if uf.find(l) != uf.find(r)
        edge_count += 1
        break if edge_count > 3
      end
    end
    if edge_count == 3
      return uf.set_sizes.reduce(&:*)
    end
  end
end

def karger_stein_helper(node_edges, edges)
  node_to_idx = node_edges.keys.map.with_index.to_h
  edges = edges.map do |nodes|
    nodes.map(&node_to_idx)
  end
  uf = UnionFind.new(node_to_idx.size)
  while true
    res = fast_min_cut(edges.dup, uf.dup)
    return res if res
  end
end

SQRT_2 = Math.sqrt(2)
def fast_min_cut(i_edges, i_uf)
  stack = [[i_edges, i_uf]]
  while stack.any?
    edges, uf = stack.pop
    if uf.count <= 6
      res_edges, res_uf = contract(edges, uf, 2)
      if res_edges.size == 3
        return uf.set_sizes.reduce(&:*)
      end
      next
    end
    t = (uf.count / SQRT_2).ceil + 1
    stack << contract(edges, uf.dup, t)
    stack << contract(edges, uf, t)
  end
  return nil
end

def contract(edges, uf, t)
  i = 0
  while uf.count > t
    random_i = rand((i...edges.size))
    edges[i], edges[random_i] = edges[random_i], edges[i]
    l, r = edges[i]
    i += 1
    uf.union(l, r)
  end

  new_edges = edges[i..-1]
  new_edges.reject! { |l, r| uf.find(l) == uf.find(r) }
  [
    new_edges,
    uf
  ]
end

p karger(node_edges, edges)
# p karger_stein_helper(node_edges, edges)