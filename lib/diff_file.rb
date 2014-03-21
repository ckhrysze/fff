class DiffFile
  attr_accessor :filename, :range_info, :lines, :changes

  def initialize(filename)
    @filename = filename.slice(/b\/(.*)/, 1)
    @lines = []
    @changes = 0
  end

  def range_info=(info)
    @lines.push(DiffLine.new(' ', ' ', ' ', 'rangeinfo', info))

    parts = info.split
    range_a = parts[1].slice(1..-1).split(',')
    range_b = parts[2].slice(1..-1).split(',')

    # -1 because I'm lazy and its easier to always add 1 later
    @file_a_current = range_a.first.to_i-1
    @file_b_current = range_b.first.to_i-1
  end

  def add_line(line)
    line_a = line_b = ' '
    status = 'nochange'

    sym = line[0]
    case sym
    when '+'
      @changes += 1
      @file_b_current += 1
      line_b = @file_b_current
      status = 'added'
    when '-'
      @changes += 1
      @file_a_current += 1
      line_a = @file_a_current
      status = 'removed'
    else
      @file_a_current += 1
      @file_b_current += 1
      line_b = @file_b_current
      line_a = @file_a_current
    end

    content = line[1..-1]
    @lines.push(DiffLine.new(
        line_a,
        line_b,
        sym,
        status,
        content
        ))
  end
end
