require_relative 'comparable'

class Node
  include Comparable
  attr_accessor :value, :left_child, :right_child, :depth

  def initialize(value = nil, depth = nil)
    self.value = value
    self.depth = depth
    self.left_child = nil
    self.right_child = nil
  end

  def set_left(node)
    self.left_child = node
  end

  def set_right(node)
    self.right_child = node
  end

  def get_child
    child_flag = []
    self.left_child.nil? ? child_flag[0] = 0 : child_flag[0] = 1
    self.right_child.nil? ? child_flag[1] = 0 : child_flag[1] = 1 
    child_flag
  end
end 