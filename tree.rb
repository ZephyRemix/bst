require_relative 'node'
require 'pry-byebug'

class Tree
  attr_accessor :array, :root

  def initialize(array)
    self.array = array.uniq.sort
    self.root = nil
  end

  def build_tree(start = 0, last = self.array.size)
    # binding.pry
    return nil if start > last

    mid = (start + last) / 2
    root = Node.new(self.array[mid])

    root.set_left(build_tree(start, mid-1))
    root.set_right(build_tree(mid+1, last))

    self.root = root
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right_child, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right_child
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.value}"
    pretty_print(node.left_child, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left_child
  end
end

tree = Tree.new([1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324])
tree.build_tree()
tree.pretty_print