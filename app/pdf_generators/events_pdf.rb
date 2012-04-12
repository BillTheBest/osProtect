
require "open-uri"
require "osprotect/date_ranges"
require "osprotect/pulse_top_tens"

class EventsPdf < Prawn::Document
  include Osprotect::DateRanges
  include Osprotect::PulseTopTens

  def initialize(user, report, report_title, report_header, report_time, max_exceeded, max_events_per_pdf, events_count, events)
    super(top_margin: 30, left_margin: 5, right_margin: 5, font: "Helvetica", page_size: "A4", page_layout: :portrait)
    self.font_size = 8
    @gchart_size = '625x300'
    @user = user
    @report = report
    @report_title = report_title
    @report_header = report_header
    @report_time = report_time
    @max_exceeded = max_exceeded
    @max_events_per_pdf = max_events_per_pdf
    @events_count = events_count
    @events = events
    @coverbg = "app/assets/images/osProtect-background.jpg"

    # set_title_for_every_page
    image @coverbg, :at => [-5,805], scale: 0.48
    move_down 225
    text "Clone Systems IPS Report", size: 30, style: :bold, spacing: 4, align: :center
    move_down 20
    text @report_header, size: 19, style: :bold, spacing: 4, align: :center
    move_down 6
    text @report_time, size: 11, style: :bold, spacing: 2, align: :center
    move_down 50
    indent(238) { put_criteria_into_table }
    start_new_page
    text "Table of Contents", size: 20, style: :bold, spacing: 4, align: :center
    stroke_horizontal_line bounds.left, bounds.right
    move_down 30
    if report.include_summary
      text "<link anchor='section1'>Top Attackers</link>" + " ." * 70, :inline_format=>true, size: 12
      text "<link anchor='section2'>Top Targets</link>" + " ." * 72, :inline_format=>true, size: 12
      text "<link anchor='section3'>Attack Priorities</link>" + " ." * 69, :inline_format=>true, size: 12
      text "<link anchor='section4'>Top Events by Signature</link>" + " ." * 62, :inline_format=>true, size: 12
    end
    text "<link anchor='section5'>Detailed View of Events</link>" + " ." * 63, :inline_format=>true, size: 12
    if report.include_summary
      move_up 70
      text "<link anchor='section1'>Page 3</link>", :inline_format=>true, size: 12, align: :right
      text "<link anchor='section2'>Page 3</link>", :inline_format=>true, size: 12, align: :right
      text "<link anchor='section3'>Page 4</link>", :inline_format=>true, size: 12, align: :right
      text "<link anchor='section4'>Page 4</link>", :inline_format=>true, size: 12, align: :right
      lpage = "Page 5"
    else
      move_up 14
      lpage = "Page 3"
    end
    text "<link anchor='section5'>#{lpage}</link>", :inline_format=>true, size: 12, align: :right
    create_summary if report.include_summary
    start_new_page
    add_dest('section5', dest_fit_horizontally(cursor, page.dictionary))
    text "Detailed View of Events", size: 15, style: :bold, spacing: 4, align: :left
    move_down 10
    if @max_exceeded
      stroke_horizontal_line bounds.left, bounds.right
      move_down 10
      indent(15) do
        text "There were #{events_count} matching Events. This exceeds the maximum of #{@max_events_per_pdf} per PDF. Only #{@max_events_per_pdf} will be shown in this PDF.", size: 10, style: :bold, spacing: 4, align: :left
      end
      move_down 7
      stroke_horizontal_line bounds.left, bounds.right
      move_down 10
    end
    put_events_into_table
    # note: always do this last so Prawn's "number_pages" will number every page:
    set_footer_for_every_page
  end

  def create_summary
    take_pulse(@user, @report.report_criteria[:relative_date_range])
    stroke_color "8d8d8d" # grey
    start_new_page
    @top_attackers_text = "The Top Attackers table and graph show the top source IP addresses from which attacks originated along with the number of hits from each address. Review this information in detail and make sure the number of hits from any one IP address is not consistently high as it may represent a denial of service (DoS) attack against the environment."
    if @attackers.blank?
      add_dest('section1', dest_fit_horizontally(cursor, page.dictionary))
      text "Top Attackers", size: 15, style: :bold, spacing: 4, align: :left
      move_down 10
      text @top_attackers_text, size: 9, align: :left
      move_down 15
      text "none", size: 10, style: :bold, spacing: 4, align: :left
    else
      @attackers = @attackers.order('ipcnt DESC')
      chart_data = @attackers.map { |aip| aip.ipcnt }
      chart_labels = @attackers.map { |aip| aip.ip_source.to_s }
      move_down 80
      image gchart_image("", chart_labels, chart_data), scale: 0.75
      move_up 300
      add_dest('section1', dest_fit_horizontally(cursor, page.dictionary))
      text "Top Attackers", size: 15, style: :bold, spacing: 4, align: :left
      move_down 10
      text @top_attackers_text, size: 9, align: :left
      move_down 10
      indent(465) { create_attackers_table }
    end

    canvas do
      move_down  380
      indent(5) do
        add_dest('section2', dest_fit_horizontally(cursor, page.dictionary))
        @top_targets_text = "The Top Targets table and graph show the top destination IP addresses that were attacked and the number of hits to each address. Review this information in detail and make sure the highly targeted hosts have the latest OS and application patches applied to them and that they pass an exhaustive vulnerability scan. Internet accessible hosts should be patched and scanned on a bi-monthly basis."
        if @targets.blank?
          add_dest('section2', dest_fit_horizontally(cursor, page.dictionary))
          text "Top Targets", size: 15, style: :bold, spacing: 4, align: :left
          move_down 10
          text @top_targets_text, size: 9, align: :left
          move_down 15
          text "none", size: 10, style: :bold, spacing: 4, align: :left
        else
          @targets = @targets.order('ipcnt DESC')
          chart_data = @targets.map { |tip| tip.ipcnt }
          chart_labels = @targets.map { |tip| tip.ip_destination.to_s }
          move_down 80
          image gchart_image("", chart_labels, chart_data), scale: 0.75
          move_up 300
          add_dest('section2', dest_fit_horizontally(cursor, page.dictionary))
          text "Top Targets", size: 15, style: :bold, spacing: 4, align: :left
          move_down 10
          text @top_targets_text, size: 9, align: :left
          move_down 10
          indent(465) { create_targets_table }
        end
      end
    end

    start_new_page
    add_dest('section3', dest_fit_horizontally(cursor, page.dictionary))
    @priorities_text = "The Priority table and graph shows the total number of attacks detected based on their priority (severity) level; High, Medium or Low. High priority attacks can sometimes lead to loss of cardholder information, social security numbers, PHI or other personal information. Medium priority alerts can generally be categorized as denial of service (DoS), virus propagation, Trojans or Malware based attacks. Low priority events are early signs of unauthorized activity such as ping, port discover, illegal URL requests, etc."
    if @priorities.blank?
      add_dest('section3', dest_fit_horizontally(cursor, page.dictionary))
      text "Attack Priorities", size: 15, style: :bold, spacing: 4, align: :left
      move_down 10
      text @priorities_text, size: 9, align: :left
      move_down 15
      text "none", size: 10, style: :bold, spacing: 4, align: :left
    else
      chart_data = @priorities.map { |p| p.priority_cnt }
      chart_labels = @priorities.map { |p| p.sig_priority }
      chart_labels = chart_labels.map do |cl|
        cl = set_priority_level(cl)
      end
      move_down 80
      image gchart_image("", chart_labels, chart_data), scale: 0.75
      move_up 300
      add_dest('section3', dest_fit_horizontally(cursor, page.dictionary))
      text "Attack Priorities", size: 15, style: :bold, spacing: 4, align: :left
      move_down 5
      text @priorities_text, size: 9, align: :left
      move_down 6
      indent(465) { create_priorities_table }
    end

    canvas do
      move_down  380
      indent(5) do
        add_dest('section4', dest_fit_horizontally(cursor, page.dictionary))
        text "Top Events by Signature", size: 15, style: :bold, spacing: 4, align: :left
        move_down 10
        if @events_by_signature.blank?
          text "none", size: 10, style: :bold, spacing: 4, align: :left
        else
          @events_by_signature = @events_by_signature.order('event_cnt DESC')
          chart_data = @events_by_signature.map { |ebs| ebs.event_cnt }
          chart_labels = @events_by_signature.map { |ebs| ebs.sig_name }
          # cls: signature names have bizarre characters in them which is bad for gcharts, so don't do:
          # image gchart_image("", chart_labels, chart_data), scale: 0.75
          indent(0) { create_events_by_signature_table }
        end
      end
    end
    # note: the sql used to find the most active times is too slow, so this is disabled:
    # start_new_page
    # move_down 5
    # text "Most Active Times", size: 15, style: :bold, spacing: 4, align: :center
    # stroke_horizontal_line bounds.left, bounds.right
    # move_down 30
    # text "15 minute intervals with more than 10 events", size: 10, spacing: 4, align: :center
    # move_down 10
    # if @hot_times.blank?
    #   text "none", size: 10, style: :bold, spacing: 4, align: :center
    # else
    #   indent(200) { create_most_active_times_table }
    # end
  end

  def gchart_image(chart_title, chart_labels, chart_data)
    # note that the gem googlecharts generates something like this:
    # "http://chart.apis.google.com/chart?chco=FFF804,336699,339933,ff0000,cc99cc,cf5910&chf=bg,s,FFFFFF&chd=s:9JBBAA&chl=19.168.1.3|19.168.1.4|19.168.1.8|10.81.4.130|0.0.0.1|0.0.4.87&chtt=&cht=p3&chs=900x300&chxr=0,1561,1561"
    img = URI.parse(URI.encode(Gchart.pie_3d(data: chart_data, labels: chart_labels, size: @gchart_size, title: chart_title, theme: :thirty7signals))).to_s
    img = open(img)
  end

  # note: the sql used to find the most active times is too slow, so this is disabled:
  # def create_most_active_times_table
  #   atable =  [ ["count", "Most Active Times (UTC)"] ] + 
  #     @hot_times.map do |hot_time|
  #       s = hot_time.minute
  #       e = hot_time.minute + 15.minutes
  #       [hot_time.cnt, s.strftime("%l:%M") + ' - ' + e.strftime("%l:%M %P")]
  #     end
  #   table atable do
  #     self.header = true
  #     row(0).background_color = "5D829F"
  #     row(0).text_color = "FFFFFF"
  #     row(0).font_style = :bold
  #     self.row_colors = ["D4E1EF", "FFFFFF"]
  #     self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "D4E1EF"}
  #     self.columns(0).align = :right
  #   end
  # end

  def create_attackers_table
    atable =  [ ["Count", "Top Attackers"] ] + @attackers.map { |aip| [aip.ipcnt, aip.ip_source.to_s] }
    table atable do
      self.header = true
      row(0).background_color = "5D829F"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      self.row_colors = ["D4E1EF", "FFFFFF"]
      self.width = 120
      self.column_widths = [45, 75]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "D4E1EF"}
      self.columns(0).align = :right
    end
  end

  def create_targets_table
    atable =  [ ["Count", "Top Targets"] ] + @targets.map { |tip| [tip.ipcnt, tip.ip_destination.to_s] }
    table atable do
      self.header = true
      row(0).background_color = "5D829F"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      self.row_colors = ["D4E1EF", "FFFFFF"]
      self.width = 120
      self.column_widths = [45, 75]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "D4E1EF"}
      self.columns(0).align = :right
    end
  end

  def create_priorities_table
    priority_table_updated = []
    priority_table = @priorities.map { |p| [p.priority_cnt, p.sig_priority] }
    priority_table_flatten = priority_table.flatten
    priority_cnt = priority_table_flatten.columnize :columns => 2, :offset => 0
    sig_priority = priority_table_flatten.columnize :columns => 2, :offset => 1
    sig_priority = sig_priority.map do |key|
      priority_table_updated << [ priority_cnt[key-1], set_priority_level(key) ]
    end
    atable =  [ ["Count", "Priorities"] ] + priority_table_updated
    table atable do
      self.header = true
      row(0).background_color = "5D829F"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      self.row_colors = ["D4E1EF", "FFFFFF"]
      self.width = 120
      self.column_widths = [45, 75]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "D4E1EF"}
      self.columns(0).align = :right
    end
  end

  def create_events_by_signature_table
    atable =  [ ["Count", "Top Events by Signature"] ] + @events_by_signature.map { |ebs| [ebs.event_cnt, ebs.sig_name] }
    table atable do
      self.header = true
      row(0).background_color = "5D829F"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      self.row_colors = ["D4E1EF", "FFFFFF"]
      self.width = 585
      self.column_widths = [60, 525]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "D4E1EF"}
      self.columns(0).align = :right
    end
  end

  def put_criteria_into_table
    criteria_table =  @report.report_criteria.map do |key, value|
                        k = "Priority:"          if key == "sig_priority"
                        if key == "sig_id"
                          k = "Signature:"
                          value = SignatureDetail.find(value).sig_name unless value.blank?
                        end
                        k = "Source IP:"         if key == "source_address"
                        k = "Source Port:"       if key == "source_port"
                        k = "Destination IP:"    if key == "destination_address"
                        k = "Destination Port:"  if key == "destination_port"
                        if key == "sensor_id"
                          k = "Sensor:"
                          value = Sensor.find(value).hostname unless value.blank?
                        end
                        k = "Date Range:"        if key == "relative_date_range"
                        k = "Begin Date:"        if key == "timestamp_gte"
                        k = "End Date:"          if key == "timestamp_lte"
                        [k, value]
                      end
    criteria_table = criteria_table.reject{ |k, value| value.strip.length == 0 }
    table criteria_table do
      self.header = false
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 0}
    end
  end

  def put_events_into_table
    events_table =  set_table_header_row + 
                    @events.map do |event|
                      [event.priority, event.signature, event.source_ip_port, event.destination_ip_port, event.sensor_name, event.timestamp.to_s]
                    end
    table events_table do
      self.header = true
      row(0).background_color = "5D829F"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      # comment the width attributes below to let prawn figure this stuff out:
      self.width = 585
      self.column_widths = [38, 154, 91, 91, 109, 102]
      # puts "\nself.width=#{self.width}\n"
      self.row_colors = ["D4E1EF", "FFFFFF"]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "D4E1EF"}
    end
  end

  def set_table_header_row
    [ ["Priority", "Signature", "Source", "Destination", "Sensor", "Timestamp"] ]
  end

  def set_title_for_every_page
    repeat :all do
      text_box @report_title, at: [5, (bounds.top + 20)], size: 10, style: :bold, align: :center
    end
  end

  def set_footer_for_every_page
    page_footerL = "#{Time.now.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z")}"
    page_optionsL = {:at => [5, 0],
                    # :color => "007700",
                    :width => 400,
                    :page_filter => :all,
                    :align => :left,
                    :start_count_at => 1 }
    number_pages page_footerL, page_optionsL

    page_footerR = "page <page> of <total>"
    page_optionsR = {:at => [bounds.right - 405, 0],
                    :width => 400,
                    :page_filter => :all,
                    :align => :right,
                    :start_count_at => 1 }
    number_pages page_footerR, page_optionsR
  end

  def set_priority_level(key)
    if key == 1
      prrty = "High"
    elsif key == 2
      prrty = "Medium"
    elsif key == 3
      prrty = "Low"
    end
    return prrty
  end
end
