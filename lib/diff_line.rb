class DiffLine
  attr_accessor :left_line_number, :right_line_number, :status_symbol, :status, :content

  def initialize(left, right, sym, st, content)
    @left_line_number = left
    @right_line_number = right
    @status_symbol = sym
    @status = st
    @content = content
  end
end
