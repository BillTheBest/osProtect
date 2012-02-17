class EventsPdf < Prawn::Document
  def initialize(events, search_params)
    super(top_margin: 30, left_margin: 5, right_margin: 5, font: "Helvetica", page_size: "A4", page_layout: :portrait)
    self.font_size = 8
    @events = events
    set_title_for_every_page
    if search_params.nil?
      text "No search criteria was specified."
    else
      move_down 20
      @criteria = search_params
      put_criteria_into_table
    end
    start_new_page
    put_events_into_table
    # note: always do this last so Prawn's "number_pages" will number every page:
    set_footer_for_every_page
  end

  def put_criteria_into_table
    criteria_table =  [ ["criteria", "value"] ] + 
                      @criteria.map do |key, value|
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
      # self.cell_style = {border_width: 1, borders: [:left, :right, :bottom], border_color: "F0F0F0"}
    end
  end
  
  def set_table_header_row
    [ ["priority", "signature", "source", "destination", "sensor", "timestamp"] ]
  end
  
  def set_title_for_every_page
    repeat :all do
      tl = bounds.top_left # this is an array and we want to change the value at [1]:
      text_box "Events Report      #{Time.now.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z")}", at: [30, tl[1]+20], size: 20, style: :bold, align: :center
    end
  end
  
  def set_footer_for_every_page
    page_footer = "page <page> of <total>"
    page_options = {:at => [bounds.right - 150, 0],
                    # :color => "007700",
                    :width => 150,
                    :page_filter => :all,
                    :align => :right,
                    :start_count_at => 1 }
    number_pages page_footer, page_options
  end
end