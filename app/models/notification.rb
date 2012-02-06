class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  has_many :notification_results, dependent: :destroy

  serialize :notify_criteria

  attr_accessible :user_id, :email, :run_status, :last_run, :notify_criteria, :priority_ids
  attr_reader :priority_ids

  # validates :run_status, presence: true
  validates :priority_ids, presence: {message: "at least one must be selected"}

  def priority_ids=(ids)
    return if ids.blank? || ids.length < 1 || ids[0].blank?
    @priority_ids = ids
    self.notify_criteria = self.priority_ids
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
