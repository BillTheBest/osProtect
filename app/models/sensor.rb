class Sensor < ActiveRecord::Base
  # set_table_name 'sensor'
  self.pluralize_table_names = false
  # set_primary_key 'sid' # deprecated in rails 3.2.0, instead do:
  self.primary_key = 'sid'
  alias_attribute :id, :sid

  belongs_to :sensor_detail, :foreign_key => 'detail'
  belongs_to :sensor_encoding, :foreign_key => 'encoding'
  has_many :events, :foreign_key => 'sid'
  has_one :sensor_name

  attr_accessible :name
  attr_accessor :name

  UNNAMED = "none"

  def name
    sn = self.sensor_name
    return UNNAMED if sn.nil?
    return sn.name unless sn.name.blank?
    UNNAMED
  end

  def self.selections(user)
    # note: if user is an admin, groups/memberships don't matter since an admin can do anything:
    if user.role? :admin
      sensors = self.select('sid, hostname').all
    else
      # get user's sensors based on group memberships:
      sensors_for_user = user.sensors
      if sensors_for_user.blank?
        sensors = []
        flash.now[:error] = "No sensors were found for you, perhaps you are not a member of any group. Please contact an administrator to resolve this issue."
        return
      else
        # limit Sensors based on this user's groups/memberships:
        sensors = self.where("sensor.sid IN (?)", sensors_for_user).select('sid, hostname').all
      end
    end
    sensors
  end
end
