class Changelog
  attr_accessor :author, :version, :overview, :changes, :files

  def initialize
    @changes = {}
    @diffed_files = {}
  end

  def add_change(title, point)
    @changes[title] ||= []
    @changes[title].push(point)
  end

  def add_diff_file(filename)

    file = nil
    File.open(filename).each do |line|
      case line
      when /^diff\s/
        parts = line.split()
        newfile = DiffFile.new(parts.last)

        if file.nil?
          file = newfile
        else
          @diffed_files[file.filename] = file
          file = newfile unless file.filename == newfile.filename
        end
      when /^index\s/, /^\-{3}/, /^\+{3}/, /^(new|old)\s(file\s|file\s)?mode/, /^ewfild\smode/, /^\\\sNo newline/
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
    @diffed_files[file.filename] = file

    @files = @diffed_files.values
  end

  def export_html(filename)
    stylesheet = File.read('assets/format.css')
    tmpl = ERB.new(File.read('assets/tmpl.html'))

    #for bindings to work
    changelog = self
    width = 650

    File.open(filename, 'w') do |f|
      f.puts tmpl.result(binding)
    end
  end

  def export_pdf(filename)
    stylesheet = File.read('assets/format.css')
    tmpl = ERB.new(File.read('assets/tmpl.html'))

    #for bindings to work
    changelog = self
    width = 650

    # run `wkhtmltopdf --extended-help` for a full list of options
    html = tmpl.result(binding)
    kit = PDFKit.new(html) #, :page_size => 'Letter')
    kit.to_file(filename)

  end

end
