require_relative 'comparable'

class Node
  include Comparable
  attr_accessor :value, :left_child, :right_child

  def initialize(value = nil)
    self.value = value
    self.left_child = nil
    self.right_child = nil
  end

  def set_left(node)
    self.left_child = node
  end

  def set_right(node)
    self.right_child = node
  end
end 