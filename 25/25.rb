
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

p karger(node_edges, edges)