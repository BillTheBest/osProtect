class SensorEncoding < ActiveRecord::Base
  set_table_name 'encoding'
  self.pluralize_table_names = false
  set_primary_key 'encoding_type'
  alias_attribute :id, :encoding_type

  has_many :sensors, :class_name => "Sensor", :foreign_key => 'encoding', :primary_key => 'encoding_type'
end
