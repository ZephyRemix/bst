module Comparable
  def compare(curr_val, new_val)
    case true
    when new_val == curr_val; return 0
    when new_val > curr_val; return 1
    when new_val < curr_val; return -1
    end
  end
end