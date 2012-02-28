# require "#{Rails.root}/lib/osprotect/date_ranges"
require "osprotect/date_ranges"

class EventSearch
  include ActiveModel::Validations
  include ActiveModel::AttributeMethods

  include Osprotect::DateRanges

  attr_accessor :searchable, :start_time, :end_time

  attribute_method_suffix  "="  # attr_writers
  # attribute_method_suffix  ""   # attr_readers

  define_attribute_methods [:sig_priority, :sig_id,
                            :source_address, :source_port,
                            :destination_address, :destination_port,
                            :sensor_id, :timestamp_gte, :timestamp_lte,
                            :relative_date_range
                           ]

  # ActiveModel expects attributes to be stored in @attributes as a hash (see: set_attributes)
  attr_reader :attributes

  def initialize(params)
    set_attributes
    @searchable = params.blank? ? false : true
    return unless @searchable
    self.sig_priority = params[:sig_priority]
    self.sig_id = params[:sig_id]
    self.source_address = params[:source_address]
    ip_ok = Iphdr.is_valid?(self.source_address)
    self.errors['Source address'] << "is invalid" unless ip_ok
    self.source_port = params[:source_port]
    self.errors['Source port'] << "must be a number" unless Iphdr.numeric?(self.source_port)
    self.destination_address = params[:destination_address]
    ip_ok = Iphdr.is_valid?(self.destination_address)
    self.errors['Destination address'] << "is invalid" unless ip_ok
    self.destination_port = params[:destination_port]
    self.errors['Destination port'] << "must be a number" unless Iphdr.numeric?(self.destination_port)
    self.sensor_id = params[:sensor_id]
    self.relative_date_range = params[:relative_date_range] || ''
    self.timestamp_gte = params[:timestamp_gte] || ''
    self.errors['Beginning date'] << "is invalid" unless valid_date? timestamp_gte
    self.timestamp_lte = params[:timestamp_lte] || ''
    self.errors['Ending date'] << "is invalid" unless valid_date? timestamp_lte
  end

  def reset_search
    set_attributes
  end

  def filter(events)
    set_time_range(relative_date_range) # sets: @start_time and @end_time
    return events unless @searchable
    events = events.where("signature.sig_priority = ?", sig_priority) unless sig_priority.blank?
    events = events.where("signature.sig_id = ?", sig_id) unless sig_id.blank?
    events = events.where("iphdr.ip_src = ?", Iphdr.to_numeric(source_address)) unless source_address.blank?
    events = events.where("(udphdr.udp_sport = ? OR tcphdr.tcp_sport = ?)", source_port.to_i, source_port.to_i) unless source_port.blank?
    events = events.where("iphdr.ip_dst = ?", Iphdr.to_numeric(destination_address)) unless destination_address.blank?
    events = events.where("(udphdr.udp_dport = ? OR tcphdr.tcp_dport = ?)", destination_port.to_i, destination_port.to_i) unless destination_port.blank?
    events = events.where(sid: sensor_id) unless sensor_id.blank?
    if @start_time.nil? || @end_time.nil?
      @start_time = timestamp_gte.to_datetime.utc.beginning_of_day unless timestamp_gte.blank?
      @end_time = timestamp_lte.to_datetime.utc.end_of_day unless timestamp_lte.blank?
      # try custom/fixed date range:
      events = events.where("timestamp >= ?", @start_time) unless timestamp_gte.blank?
      events = events.where("timestamp <= ?", @end_time) unless timestamp_lte.blank?
    else
      events = events.where('timestamp between ? and ?', @start_time, @end_time)
    end
    # puts "\n events=#{events.to_sql}\n"
    events
  end

  private

  def valid_date?(adate)
    # Date.parse(adate)
    adate.to_date
    true
  rescue Exception => e
    false
  end

  def set_attributes
    @attributes = Hash.new
    @attributes[:sig_priority] = ''
    @attributes[:sig_id] = ''
    @attributes[:source_address] = ''
    @attributes[:source_port] = ''
    @attributes[:destination_address] = ''
    @attributes[:destination_port] = ''
    @attributes[:sensor_id] = ''
    @attributes[:timestamp_gte] = ''
    @attributes[:timestamp_lte] = ''
    @attributes[:relative_date_range] = ''
    self.errors.clear if self.errors.size > 0
  end

  # acts as attribute writers via method_missing
  def attribute=(attr, value)
    @attributes[attr] = value
  end

  # acts as attribute readers via method_missing
  def attribute(attr)
    @attributes[attr]
  end
end
