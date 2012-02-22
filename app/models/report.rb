class Report < ActiveRecord::Base
  belongs_to :user
  has_many :report_groups, dependent: :destroy
  has_many :groups, through: :report_groups
  has_many :pdfs, dependent: :destroy

  serialize :report_criteria, ActiveSupport::HashWithIndifferentAccess

  attr_accessible :group_ids, :user_id, :accessible_by, :report_type, :for_all_users, :name, :include_summary, :auto_run_at, :run_status, :report_criteria, :report_criteria_as_string

  attr_accessor :accessible_by

  before_validation :set_report_criteria_as_string

  validates :report_criteria_as_string, uniqueness: {scope: :user_id, message: "you already have a Report with the same criteria!"}
  validates :name, presence: true
  validate :source_address_ok
  validate :source_port_ok
  validate :destination_address_ok
  validate :destination_port_ok
  validate :timestamp_gte_ok
  validate :timestamp_lte_ok
  validate :date_range_presence
  validate :date_range_is_relative_or_fixed_but_not_both
  validate :date_range_is_fixed_so_both_dates_required
  validate :date_range_is_fixed_so_range_must_be_proper

  class Selection
    attr_accessor :id, :name
    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end unless attributes.nil?
    end
  end

  def self.relative_date_ranges
    rdr = []
    rdr << Selection.new({id: 'today',      name: 'Today'})
    rdr << Selection.new({id: 'last_24',    name: 'Last 24 Hours'})
    rdr << Selection.new({id: 'week',       name: 'This Week'})
    rdr << Selection.new({id: 'last_week',  name: 'Last Week'})
    rdr << Selection.new({id: 'month',      name: 'This Month'})
    rdr << Selection.new({id: 'past_year',  name: 'Past Year'})
    rdr << Selection.new({id: 'year',       name: 'Year'})
    rdr
  end

  def self.auto_run_selections
    ar = []
    ar << Selection.new({id: 'd', name: 'Daily'})
    ar << Selection.new({id: 'w', name: 'Weekly'})
    ar << Selection.new({id: 'm', name: 'Monthly'})
    ar
  end

  def self.access_allowed_selections(user)
    ar = []
    ar << Selection.new({id: 'm', name: 'only me'})
    ar << Selection.new({id: 'a', name: 'any group or user'}) if user && user.role?(:admin)
    ar << Selection.new({id: 'g', name: 'for group(s) selected below'})
    ar
  end

  def enabled
    self.run_status == true
  end

  def disabled
    self.run_status == false
  end

  def status
    self.run_status ? 'enabled' : 'disabled'
  end

  def group_ids_as_array
    gids = []
    self.groups.map {|g| gids << g.id}
    gids
  end

  private

  def set_report_criteria_as_string
    self.report_criteria_as_string = "report=#{self.report_type}," + self.report_criteria.to_s
  end

  def source_address_ok
    self.errors[:source_address] << "is invalid" unless Iphdr.is_valid?(self.report_criteria[:source_address])
  end

  def source_port_ok
    self.errors[:source_port] << "must be a number" unless Iphdr.numeric?(self.report_criteria[:source_port])
  end

  def destination_address_ok
    self.errors[:destination_address] << "is invalid" unless Iphdr.is_valid?(self.report_criteria[:destination_address])
  end

  def destination_port_ok
    self.errors[:destination_port] << "must be a number" unless Iphdr.numeric?(self.report_criteria[:destination_port])
  end

  def timestamp_gte_ok
    self.errors[:timestamp_gte] << "is invalid" unless valid_date? self.report_criteria[:timestamp_gte]
  end

  def timestamp_lte_ok
    self.errors[:timestamp_lte] << "is invalid" unless valid_date? self.report_criteria[:timestamp_lte]
  end

  def date_range_presence
    self.errors[:date_range] << "a relative or fixed date range is required" if self.report_criteria[:relative_date_range].blank? && self.report_criteria[:timestamp_gte].blank? && self.report_criteria[:timestamp_lte].blank?
  end

  def date_range_is_relative_or_fixed_but_not_both
    self.errors[:date_range] << "can not be both relative and fixed, please enter only a relative or fixed date range" if self.report_criteria[:relative_date_range].present? && (self.report_criteria[:timestamp_gte].present? || self.report_criteria[:timestamp_lte].present?)
  end

  def date_range_is_fixed_so_both_dates_required
    if (self.report_criteria[:timestamp_lte].present? && self.report_criteria[:timestamp_gte].blank?) ||
       (self.report_criteria[:timestamp_gte].present? && self.report_criteria[:timestamp_lte].blank?)
      self.errors[:fixed_date_range] << "both dates are required when either is entered"
    end
  end

  def date_range_is_fixed_so_range_must_be_proper
    return if self.report_criteria[:timestamp_lte].blank? && self.report_criteria[:timestamp_gte].blank?
    begin
      self.errors[:fixed_date_range] << "begin and end dates must specify a proper range" if self.report_criteria[:timestamp_lte].to_date < self.report_criteria[:timestamp_gte].to_date
    rescue Exception => e
      return # invalid dates already handled by another validation
    end
  end

  def valid_date?(adate)
    adate.to_date
    true
  rescue Exception => e
    false
  end
end
