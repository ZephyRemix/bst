require_relative 'node'
require 'pry-byebug'

class Tree
  attr_accessor :array, :root

  def initialize(array)
    self.array = array.uniq.sort
    self.root = nil
  end

  def build_tree(start = 0, last = self.array.size)
    return nil if start > last

    mid = (start + last) / 2
    root = Node.new(self.array[mid])

    root.set_left(build_tree(start, mid-1))
    root.set_right(build_tree(mid+1, last))

    self.root = root
  end

  def insert(value)
    prev_node = nil
    curr_node = self.root
    res = nil

    while curr_node != nil
      # binding.pry
      case res = curr_node.compare(curr_node.value, value)
      when 1
        prev_node = curr_node
        curr_node = curr_node.right_child
      when -1
        prev_node = curr_node
        curr_node = curr_node.left_child
      when 0; break
      end
    end
    # at the end of the tree where self.root == nil
    curr_node = Node.new(value)
    # binding.pry
    case res
    when 1
      prev_node.set_right(curr_node)
    when -1 
      prev_node.set_left(curr_node)
    end
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right_child, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right_child
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.value}"
    pretty_print(node.left_child, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left_child
  end
end

tree = Tree.new([1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324])
tree.build_tree
tree.pretty_print
tree.insert(6)
tree.insert(50)
tree.pretty_print