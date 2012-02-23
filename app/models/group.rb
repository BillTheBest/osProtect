class Group < ActiveRecord::Base
  has_many :incidents, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :group_sensors, dependent: :destroy
  has_many :sensors, through: :group_sensors
  has_many :notifications
  has_many :report_groups, dependent: :destroy

  attr_accessible :name, :user_ids, :user_tokens, :sensor_ids
  attr_reader :user_tokens

  validates :name, presence: true
  validates :sensor_ids, presence: {message: "at least one must be selected", unless: :group_is_admins?}
  validates :user_ids, presence: {message: "at least one must be selected"}

  after_save :change_role_to_admin_for_admins_group

  def group_is_admins?
    self.name.downcase == 'admins'
  end

  def user_tokens=(ids)
    self.user_ids = ids.split(",")
  end

  private

  def change_role_to_admin_for_admins_group
    if self.group_is_admins?
      # the default role is 'user' so let's change it to 'admin'
      Membership.transaction do
        self.memberships.each do |member|
          member.role = 'admin'
          member.save(validate: false)
        end
      end
    end
  end
end
