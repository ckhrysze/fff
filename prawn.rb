Prawn::Document.generate("change_log.pdf") do |pdf|
  #pdf.text("SHFL RGS Update", :align => :center, :size => 20)
  #pdf.text("Prepared by: #{changelog.author}", :align => :center, :size => 12)
  #pdf.text("version: #{changelog.version}", :align => :center, :size => 12)
  #pdf.start_new_page
  #
  #pdf.text("Overview", :size => 20)
  #changelog.overview.each do |p|
  #  pdf.text(p)
  #end
  #pdf.start_new_page
  #
  #pdf.text("Change Log", :size => 20)
  #changelog.changes.each do |title, list|
  #  pdf.text(title.to_s, :size => 14)
  #  list.each do |point|
  #    pdf.text(point)
  #  end
  #end
  #pdf.start_new_page
  #
  #pdf.text("File Changes", :size => 20)

  files.each do |file|

    title = pdf.make_table(
      [[file.changes.to_s, '', '', file.filename]],
      :cell_style => {:background_color => 'cccccc'}
      )
    data = [[title]]

    file.lines.each do |line|

      bkcolor = case line.status
                when 'removed'; 'ffdddd'
                when 'added'; 'ddffdd'
                else; 'FFFFFF'
                end
      
      row = pdf.make_table(
        [[  line.left_line_number.to_s,
            line.right_line_number.to_s,
            line.status_symbol,
            line.content
          ]],
        :cell_style => {:background_color => bkcolor})

      
      data.push([row])
    end
    pdf.table(data)
    pdf.move_down 10
  end

end
