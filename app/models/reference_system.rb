class ReferenceSystem < ActiveRecord::Base
  set_table_name 'reference_system'
  self.pluralize_table_names = false
  set_primary_key 'ref_system_id'
  alias_attribute :id, :ref_system_id

  has_many :references, :class_name => "Reference", :foreign_key => 'ref_system_id', :primary_key => 'ref_system_id'
end
