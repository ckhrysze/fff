require 'erb'

class DiffFile
  attr_accessor :filename, :range_info, :lines, :changes

  def initialize(filename)
    @filename = filename.slice(/b\/(.*)/, 1)
    @lines = []
    @changes = 0
  end

  def range_info=(info)
    @lines.push(DiffLine.new('', '', '', 'rangeinfo', info))

    parts = info.split
    parts.shift # ignore @@ prefix
    parts.pop # ignore @@ suffix

    range_a = parts.first.slice(1..-1).split(',')
    @file_a_start = range_a.first
    @file_a_lines = range_a.last

    range_b = parts.last.slice(1..-1).split(',')
    @file_b_start = range_b.first
    @file_b_lines = range_b.last

    # -1 because I'm lazy and its easier to always add 1 later
    @file_a_current = @file_a_start.to_i-1
    @file_b_current = @file_b_start.to_i-1
  end

  def add_line(line)
    line_a = line_b = ''
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

files = {}

file = nil
File.open('example.diff').each do |line|
  case line
  when /^diff\s/
    parts = line.split()
    newfile = DiffFile.new(parts.last)

    if file.nil?
      file = newfile
    else
      files[file.filename] = file
      file = newfile unless file.filename == newfile.filename
    end
  when /^index\s/, /^\-{3}/, /^\+{3}/, /^new\sfile\smode/
    next
  when /^@@/
    file.range_info = line
  else
    begin
      file.add_line(line)
    rescue => e
      puts line
      exit(1)
    end
  end
end
files[file.filename] = file

width = 650

files = files.values

tmpl = ERB.new(File.read('tmpl.html'))
File.open('result.html', 'w') do |f|
  f.puts tmpl.result(binding)
end

