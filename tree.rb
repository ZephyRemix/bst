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
      case res = curr_node.compare(curr_node.value, value)
      when 1
        prev_node = curr_node
        curr_node = curr_node.right_child
      when -1
        prev_node = curr_node
        curr_node = curr_node.left_child
      when 0; return
      end
    end

    # insert new leaf node
    curr_node = Node.new(value) if curr_node.nil?
    res == 1 ? prev_node.set_right(curr_node) : prev_node.set_left(curr_node)
  end

  def delete(value)
    prev_node = nil
    curr_node = self.root

    # loop through tree, and find node.value that matches value
    while curr_node != nil
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

    case curr_node.get_child
    # scenario 1: delete leaf node
    when [0,0]
      prev_node.left_child.value == curr_node.value ? prev_node.set_left(nil) : prev_node.set_right(nil)

    # scenario 2: delete node with 1 child
    when [1,0]
      prev_node.left_child.value == curr_node.value ? prev_node.set_left(curr_node.left_child) : prev_node.set_right(curr_node.left_child)
    when [0,1]
      prev_node.left_child.value == curr_node.value ? prev_node.set_left(curr_node.right_child) : prev_node.set_right(curr_node.right_child)

    # scenario 3: delete node with 2 children
    when [1,1]
      replacement_node, prev_node = self.get_next_larger_node(curr_node)
      curr_node.value = replacement_node.value
      case replacement_node.get_child
      # scenario 3.1: replacement node has no child nodes
      when [0,0]
        prev_node.set_right(nil)
      # scenario 3.2: replacement node has 1 right child node
      when [0,1]
        prev_node.set_left(replacement_node.right_child)
      end
    end
  end

  def find(value)
    curr_node = self.root

    while curr_node != nil
      case res = curr_node.compare(curr_node.value, value)
      when 1; curr_node = curr_node.right_child
      when -1; curr_node = curr_node.left_child
      when 0; return curr_node
      end
    end
  end

  def level_order
    q = self.bfs

    return q if !block_given?
 
    q.each do |node|
      yield node if !node.value.nil?
    end
  end

  # def preorder(node = self.root, q = [], &blk)
  #   # binding.pry
  #   if !block_given?
  #     return q if node.nil?

  #     q << node
  #     q = preorder(node.left_child, q)
  #     q = preorder(node.right_child, q)
  #     return q

  #   elsif block_given?
  #     return if node.nil?

  #     blk.call(node.value) 
  #     preorder(node.left_child, blk) {|node| p node}
  #     preorder(node.right_child, blk) {|node| p node}
  #   end
  # end

  def preorder(node = self.root, q = [], &blk)
    # binding.pry
    return q if node.nil?

    block_given? ? blk.call(node) : q << node

    preorder(node.left_child, q, &blk)
    preorder(node.right_child, q, &blk)
    return q
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right_child, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right_child
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.value}"
    pretty_print(node.left_child, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left_child
  end

  private

  def get_next_larger_node(target_node)
    # start from right sub-tree of target_node
    prev_node = target_node
    curr_node = target_node.right_child

    while curr_node.left_child != nil
      prev_node = curr_node
      curr_node = curr_node.left_child
    end

    return curr_node, prev_node
  end

  def bfs

    q = Array.new()
    q << self.root
    i = 0

    while !q[i].nil?
      curr_node = q[i]
      q << q[i].left_child if !q[i].left_child.nil?
      q << q[i].right_child if !q[i].right_child.nil?
      
      i += 1
    end
    return q
  end
end

tree = Tree.new([1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324])
tree.build_tree
tree.pretty_print
# tree.insert(6)
# tree.insert(50)
# # tree.pretty_print
# tree.delete(6)
# # tree.pretty_print
# tree.delete(5)
# # tree.pretty_print
# tree.delete(9)
# # tree.pretty_print
# tree.delete(4)
# tree.pretty_print
# puts tree.find(324)
# tree.level_order {|node| puts node.value}

q = tree.preorder
q.each do |node|
  puts node.value
end