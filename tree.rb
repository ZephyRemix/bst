require_relative "node"
require "pry-byebug"
# require "standard/rake"

class Tree
  attr_accessor :array, :root

  def initialize(array)
    self.array = array.uniq.sort
    self.root = nil
  end

  def build_tree(start = 0, last = array.size - 1, depth = 1)
    return nil if start > last

    mid = (start + last) / 2
    root = Node.new(array[mid], depth)

    depth += 1
    root.set_left(build_tree(start, mid - 1, depth))
    root.set_right(build_tree(mid + 1, last, depth))

    self.root = root
  end

  def insert(value)
    prev_node = nil
    curr_node = root
    res = nil

    until curr_node.nil?
      case res = curr_node.compare(curr_node.value, value)
      when 1
        prev_node = curr_node
        curr_node = curr_node.right_child
      when -1
        prev_node = curr_node
        curr_node = curr_node.left_child
      when 0 then return
      end
    end

    # insert new leaf node
    curr_node = Node.new(value, prev_node.depth + 1) if curr_node.nil?
    (res == 1) ? prev_node.set_right(curr_node) : prev_node.set_left(curr_node)
  end

  def delete(value)
    prev_node = nil
    curr_node = root

    # loop through tree, and find node.value that matches value
    until curr_node.nil?
      case curr_node.compare(curr_node.value, value)
      when 1
        prev_node = curr_node
        curr_node = curr_node.right_child
      when -1
        prev_node = curr_node
        curr_node = curr_node.left_child
      when 0 then break
      end
    end

    case curr_node.get_child
    # scenario 1: delete leaf node
    when [0, 0]
      (prev_node.left_child.value == curr_node.value) ? prev_node.set_left(nil) : prev_node.set_right(nil)

    # scenario 2: delete node with 1 child
    when [1, 0]
      (prev_node.left_child.value == curr_node.value) ? prev_node.set_left(curr_node.left_child) : prev_node.set_right(curr_node.left_child)
    when [0, 1]
      (prev_node.left_child.value == curr_node.value) ? prev_node.set_left(curr_node.right_child) : prev_node.set_right(curr_node.right_child)

    # scenario 3: delete node with 2 children
    when [1, 1]
      replacement_node, prev_node = get_next_larger_node(curr_node)
      curr_node.value = replacement_node.value
      case replacement_node.get_child
      # scenario 3.1: replacement node has no child nodes
      when [0, 0]
        prev_node.set_right(nil)
      # scenario 3.2: replacement node has 1 right child node
      when [0, 1]
        prev_node.set_left(replacement_node.right_child)
      end
    end
  end

  def find(value)
    curr_node = root

    until curr_node.nil?
      case curr_node.compare(curr_node.value, value)
      when 1 then curr_node = curr_node.right_child
      when -1 then curr_node = curr_node.left_child
      when 0 then return curr_node
      end
    end
  end

  def level_order(root = self.root)
    q = bfs(root)

    return q if !block_given?

    q.each do |node|
      yield node if !node.value.nil?
    end
  end

  def preorder(node = root, q = [], &blk)
    return q if node.nil?

    blk ? blk.call(node) : q << node

    preorder(node.left_child, q, &blk)
    preorder(node.right_child, q, &blk)
    q
  end

  def inorder(node = root, q = [], &blk)
    return q if node.nil?

    inorder(node.left_child, q, &blk)

    blk ? blk.call(node) : q << node

    inorder(node.right_child, q, &blk)
    q
  end

  def postorder(node = root, q = [], &blk)
    return q if node.nil?

    postorder(node.left_child, q, &blk)
    postorder(node.right_child, q, &blk)

    blk ? blk.call(node) : q << node
    q
  end

  def depth(node)
    curr = root

    while curr.value != node.value
      curr = (curr.compare(curr.value, node.value) == 1) ? curr.right_child : curr.left_child
    end
    curr.depth
  end

  def height(node)
    curr_node = find(node.value)
    return 1 if curr_node.left_child.nil? && curr_node.right_child.nil?

    leaf_node = level_order(curr_node)[-1]
    leaf_node.depth - curr_node.depth + 1
  end

  def balanced?
    preorder do |node|
      l_h = (!node.left_child.nil?) ? height(node.left_child) : 0
      r_h = (!node.right_child.nil?) ? height(node.right_child) : 0
      return false if l_h - r_h > 1 || l_h - r_h < -1
    end

    true
  end

  def rebalance
    self.array = inorder.map { |node| node.value }
    build_tree
  end

  def pretty_print(node = @root, prefix = "", is_left = true)
    pretty_print(node.right_child, "#{prefix}#{is_left ? "│   " : "    "}", false) if node.right_child
    puts "#{prefix}#{is_left ? "└── " : "┌── "}#{node.value}"
    pretty_print(node.left_child, "#{prefix}#{is_left ? "    " : "│   "}", true) if node.left_child
  end

  private

  def get_next_larger_node(target_node)
    # start from right sub-tree of target_node
    prev_node = target_node
    curr_node = target_node.right_child

    until curr_node.left_child.nil?
      prev_node = curr_node
      curr_node = curr_node.left_child
    end

    [curr_node, prev_node]
  end

  def bfs(root = self.root)
    q = []
    q << root
    i = 0

    until q[i].nil?
      q << q[i].left_child if !q[i].left_child.nil?
      q << q[i].right_child if !q[i].right_child.nil?

      i += 1
    end
    q
  end
end

tree = Tree.new((Array.new(15) { rand(1..100) }))
tree.build_tree
tree.pretty_print
puts "Original tree is balanced: #{tree.balanced?}"

tree.level_order {|node| puts node.value}
tree.inorder {|node| puts node.value}
tree.preorder {|node| puts node.value}
tree.postorder {|node| puts node.value}

tree.insert(101)
tree.insert(1010)
tree.insert(200)
tree.insert(2000)
tree.pretty_print
puts "After insertion, tree is balanced: #{tree.balanced?}"

tree.rebalance
puts "Rebalanced tree is balanced: #{tree.balanced?}"
tree.pretty_print
tree.level_order {|node| puts node.value}
tree.inorder {|node| puts node.value}
tree.preorder {|node| puts node.value}
tree.postorder {|node| puts node.value}
