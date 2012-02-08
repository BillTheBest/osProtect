class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  has_many :notification_results, dependent: :destroy

  # serializing the NotificationCriteria object in/out of the notify_criteria column
  # allows us to easily alter/expand the criteria used for matching events:
  serialize :notify_criteria, NotificationCriteria

  attr_accessible :user_id, :email, :run_status, :last_run, :notify_criteria

  # virtual attributes ... these allow us to create/update the NotificationCriteria
  #                        object in the notify_criteria column:
  attr_accessible :priority_ids, :minimum_matches, :attacker_ips, :target_ips
  attr_reader :priority_ids, :minimum_matches, :attacker_ips, :target_ips
  validates :priority_ids, presence: {message: "at least one must be selected"}

  def priority_ids=(ids)
    return if ids.blank? || ids.length < 1 || ids[0].blank?
    @priority_ids = ids
    self.notify_criteria.priorities = @priority_ids
  end

  def minimum_matches=(min_count)
    return if min_count.blank?
    min_count = min_count.to_i if Integer(min_count) rescue return
    @minimum_matches = min_count
    self.notify_criteria.minimum_matches = @minimum_matches
  end

  def attacker_ips=(ips)
    @attacker_ips = ips
    self.notify_criteria.attacker_ips = @attacker_ips
  end

  def target_ips=(ips)
    @target_ips = ips
    self.notify_criteria.target_ips = @target_ips
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
end
