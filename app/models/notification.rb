class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  has_many :notification_results, dependent: :destroy

  # serializing the NotificationCriteria object in/out of the notify_criteria column
  # allows us to easily alter/expand the criteria used for matching events:
  serialize :notify_criteria, NotificationCriteria

  attr_accessible :user_id, :email, :run_status, :notify_criteria, :notify_criteria_as_string

  # virtual attributes ... these allow us to create/update the NotificationCriteria
  #                        object in the notify_criteria column:
  attr_accessible :priority_ids, :minimum_matches, :attacker_ips, :target_ips
  attr_reader :priority_ids, :minimum_matches, :attacker_ips, :target_ips
  # validates :priority_ids, presence: {message: "at least one must be selected"}
  validates :notify_criteria_as_string, uniqueness: {scope: :user_id, message: "you already have a Notification with the same criteria!"}
  validate :attacker_ips_ok
  validate :target_ips_ok

  after_validation :set_notify_criteria_as_string

  def priority_ids=(ids)
    ids = ids.compact.reject(&:blank?) # remove nil's and blank strings from ids array
    @priority_ids = ids
    self.notify_criteria.priorities = @priority_ids
    set_notify_criteria_as_string
  end

  def minimum_matches=(min_count)
    return if min_count.blank?
    min_count = min_count.to_i if Integer(min_count) rescue return
    @minimum_matches = min_count
    self.notify_criteria.minimum_matches = @minimum_matches
    set_notify_criteria_as_string
  end

  def attacker_ips=(ips)
    @attacker_ips = ips
    self.notify_criteria.attacker_ips = @attacker_ips
    set_notify_criteria_as_string
  end

  def target_ips=(ips)
    @target_ips = ips
    self.notify_criteria.target_ips = @target_ips
    set_notify_criteria_as_string
  end

  def disabled
    self.run_status == false
  end

  def status
    self.run_status ? 'enabled' : 'disabled'
  end

  def notify_email(user)
    self.email.blank? ? user.email : self.email
  end

  class Selection
    attr_accessor :id, :name
    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end unless attributes.nil?
    end
  end

  def priorities
    priorites = []
    priorites << Selection.new({id:1, name:'1'})
    priorites << Selection.new({id:2, name:'2'})
    priorites << Selection.new({id:3, name:'3'})
    priorites
  end

  private

  def set_notify_criteria_as_string
    self.notify_criteria_as_string = self.notify_criteria.to_s
  end

  def attacker_ips_ok
    self.errors[:attacker_ips] << "is invalid" unless Iphdr.is_valid?(self.attacker_ips)
  end

  validate :target_ips_ok
  def target_ips_ok
    self.errors[:target_ips] << "is invalid" unless Iphdr.is_valid?(self.target_ips)
  end
end
