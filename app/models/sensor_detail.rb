class SensorDetail < ActiveRecord::Base
  set_table_name 'detail'
  self.pluralize_table_names = false
  set_primary_key 'detail_type'
  alias_attribute :id, :detail_type

  has_many :sensors, :class_name => "Sensor", :foreign_key => 'detail', :primary_key => 'detail_type'
end
