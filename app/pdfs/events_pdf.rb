require "open-uri"
require "osprotect/date_ranges"
require "osprotect/pulse_top_tens"

class EventsPdf < Prawn::Document
  include Osprotect::DateRanges
  include Osprotect::PulseTopTens

  def initialize(user, report, events)
    super(top_margin: 30, left_margin: 5, right_margin: 5, font: "Helvetica", page_size: "A4", page_layout: :portrait)
    self.font_size = 8
    @gchart_size = '900x300'
    @user = user
    @report = report
    @events = events
    set_title_for_every_page
    move_down 20
    text "Event Selection Criteria", size: 15, style: :bold, spacing: 4, align: :center
    stroke_horizontal_line bounds.left, bounds.right
    move_down 30
    indent(200) { put_criteria_into_table }
    create_summary if report.include_summary
    start_new_page
    put_events_into_table
    # note: always do this last so Prawn's "number_pages" will number every page:
    set_footer_for_every_page
  end

  def create_summary
    take_pulse(@user, @report.report_criteria[:relative_date_range])
    stroke_color "8d8d8d" # grey
    # FIXME the following is not very DRY ... refactor soon!
    start_new_page
    move_down 20
    text "Top Attackers", size: 15, style: :bold, spacing: 4, align: :center
    stroke_horizontal_line bounds.left, bounds.right
    move_down 30
    if @attackers.blank?
      text "none", size: 10, style: :bold, spacing: 4, align: :center
    else
      @attackers = @attackers.order('ipcnt DESC')
      chart_data = @attackers.map { |aip| aip.ipcnt }
      chart_labels = @attackers.map { |aip| aip.ip_source.to_s }
      image gchart_image("", chart_labels, chart_data), scale: 0.75
      move_down 40
      indent(200) { create_attackers_table }
    end
    start_new_page
    move_down 20
    text "Top Targets", size: 15, style: :bold, spacing: 4, align: :center
    stroke_horizontal_line bounds.left, bounds.right
    move_down 30
    if @targets.blank?
      text "none", size: 10, style: :bold, spacing: 4, align: :center
    else
      @targets = @targets.order('ipcnt DESC')
      chart_data = @targets.map { |tip| tip.ipcnt }
      chart_labels = @targets.map { |tip| tip.ip_destination.to_s }
      image gchart_image("", chart_labels, chart_data), scale: 0.75
      move_down 20
      indent(200) { create_targets_table }
    end
    start_new_page
    move_down 20
    text "Priorities", size: 15, style: :bold, spacing: 4, align: :center
    stroke_horizontal_line bounds.left, bounds.right
    move_down 30
    if @priorities.blank?
      text "none", size: 10, style: :bold, spacing: 4, align: :center
    else
      chart_data = @priorities.map { |p| p.priority_cnt }
      chart_labels = @priorities.map { |p| p.sig_priority }
      image gchart_image("", chart_labels, chart_data), scale: 0.75
      move_down 20
      indent(200) { create_priorities_table }
    end
    start_new_page
    move_down 20
    text "Top Events by Signature", size: 15, style: :bold, spacing: 4, align: :center
    stroke_horizontal_line bounds.left, bounds.right
    move_down 30
    if @events_by_signature.blank?
      text "none", size: 10, style: :bold, spacing: 4, align: :center
    else
      @events_by_signature = @events_by_signature.order('event_cnt DESC')
      chart_data = @events_by_signature.map { |ebs| ebs.event_cnt }
      chart_labels = @events_by_signature.map { |ebs| ebs.sig_name }
      image gchart_image("", chart_labels, chart_data), scale: 0.75
      move_down 20
      indent(200) { create_events_by_signature_table }
    end
    start_new_page
    move_down 20
    text "Most Active Times", size: 15, style: :bold, spacing: 4, align: :center
    stroke_horizontal_line bounds.left, bounds.right
    move_down 30
    text "15 minute intervals with more than 10 events", size: 10, spacing: 4, align: :center
    move_down 10
    if @hot_times.blank?
      text "none", size: 10, style: :bold, spacing: 4, align: :center
    else
      indent(200) { create_most_active_times_table }
    end
  end

  def gchart_image(chart_title, chart_labels, chart_data)
    # note that the gem googlecharts generates something like this:
    # "http://chart.apis.google.com/chart?chco=FFF804,336699,339933,ff0000,cc99cc,cf5910&chf=bg,s,FFFFFF&chd=s:9JBBAA&chl=19.168.1.3|19.168.1.4|19.168.1.8|10.81.4.130|0.0.0.1|0.0.4.87&chtt=&cht=p3&chs=900x300&chxr=0,1561,1561"
    img = URI.parse(URI.encode(Gchart.pie_3d(data: chart_data, labels: chart_labels, size: @gchart_size, title: chart_title, theme: :thirty7signals))).to_s
    img = open(img)
  end

  def create_most_active_times_table
    atable =  [ ["count", "Most Active Times (UTC)"] ] + 
      @hot_times.map do |hot_time|
        s = hot_time.minute
        e = hot_time.minute + 15.minutes
        [hot_time.cnt, s.strftime("%l:%M") + ' - ' + e.strftime("%l:%M %P")]
      end
    table atable do
      self.header = true
      row(0).background_color = "6A7176"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      self.row_colors = ["F0F0F0", "FFFFFF"]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "F0F0F0"}
      self.columns(0).align = :right
    end
  end

  def create_attackers_table
    atable =  [ ["count", "Top Attackers"] ] + @attackers.map { |aip| [aip.ipcnt, aip.ip_source.to_s] }
    table atable do
      self.header = true
      row(0).background_color = "6A7176"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      self.row_colors = ["F0F0F0", "FFFFFF"]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "F0F0F0"}
      self.columns(0).align = :right
    end
  end

  def create_targets_table
    atable =  [ ["count", "Top Targets"] ] + @targets.map { |tip| [tip.ipcnt, tip.ip_destination.to_s] }
    table atable do
      self.header = true
      row(0).background_color = "6A7176"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      self.row_colors = ["F0F0F0", "FFFFFF"]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "F0F0F0"}
      self.columns(0).align = :right
    end
  end

  def create_priorities_table
    atable =  [ ["count", "Priorities"] ] + @priorities.map { |p| [p.priority_cnt, p.sig_priority] }
    table atable do
      self.header = true
      row(0).background_color = "6A7176"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      self.row_colors = ["F0F0F0", "FFFFFF"]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "F0F0F0"}
      self.columns(0).align = :right
    end
  end

  def create_events_by_signature_table
    atable =  [ ["count", "Top Events by Signature"] ] + @events_by_signature.map { |ebs| [ebs.event_cnt, ebs.sig_name] }
    table atable do
      self.header = true
      row(0).background_color = "6A7176"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      self.row_colors = ["F0F0F0", "FFFFFF"]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "F0F0F0"}
      self.columns(0).align = :right
    end
  end

  def put_criteria_into_table
    criteria_table =  [ ["criteria", "value"] ] + 
                      @report.report_criteria.map do |key, value|
                        k = "priority"          if key == "sig_priority"
                        if key == "sig_id"
                          k = "signature"
                          value = SignatureDetail.find(value).sig_name unless value.blank?
                        end
                        k = "source IP"         if key == "source_address"
                        k = "source port"       if key == "source_port"
                        k = "destination IP"    if key == "destination_address"
                        k = "destination port"  if key == "destination_port"
                        if key == "sensor_id"
                          k = "sensor"
                          value = Sensor.find(value).hostname unless value.blank?
                        end
                        k = "date range"        if key == "relative_date_range"
                        k = "begin date"        if key == "timestamp_gte"
                        k = "end date"          if key == "timestamp_lte"
                        [k, value]
                      end
    table criteria_table do
      self.header = true
      row(0).background_color = "6A7176"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      self.row_colors = ["F0F0F0", "FFFFFF"]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "F0F0F0"}
    end
  end

  def put_events_into_table
    # FIXME I'm guessing the @events.map is causing this to be very slow ... is there another way ?
    events_table =  set_table_header_row + 
                    @events.map do |event|
                      [event.priority, event.signature, event.source_ip_port, event.destination_ip_port, event.sensor_name, event.timestamp.to_s]
                    end
    table events_table do
      self.header = true
      row(0).background_color = "6A7176"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      # let prawn figure this stuff out:
      # self.width = 636
      # self.column_widths = [50, 142, 80, 80, 142, 142]
      # puts "\nself.width=#{self.width}\n"
      self.row_colors = ["F0F0F0", "FFFFFF"]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "F0F0F0"}
    end
  end
  
  def set_table_header_row
    [ ["priority", "signature", "source", "destination", "sensor", "timestamp"] ]
  end
  
  def set_title_for_every_page
    repeat :all do
      tl = bounds.top_left # this is an array and we want to use the value at [1]:
      text_box "Events Report", at: [30, tl[1]+20], size: 20, style: :bold, align: :center
    end
  end
  
  def set_footer_for_every_page
    page_footer = "#{Time.now.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z")}     page <page> of <total>"
    page_options = {:at => [bounds.right - 400, 0],
                    # :color => "007700",
                    :width => 400,
                    :page_filter => :all,
                    :align => :right,
                    :start_count_at => 1 }
    number_pages page_footer, page_options
  end
end