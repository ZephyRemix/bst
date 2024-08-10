require_relative 'comparable'

class Node
  include Comparable
  attr_accessor :value, :left_chid, :right_chid

  def initialize(value = nil, left_chid = nil, right_child = nil)
    self.value = value
    self.left_child = left_child
    self.right_child = right_child
  end
end 