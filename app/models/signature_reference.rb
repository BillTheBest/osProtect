class SignatureReference < ActiveRecord::Base
  set_table_name 'sig_reference'
  self.pluralize_table_names = false
  set_primary_key 'sig_class_id'
  alias_attribute :id, :sig_class_id

  has_many :signatures, :foreign_key => 'sig_id'
  has_many :references, :class_name => "Reference", :foreign_key => 'ref_id', :primary_key => 'ref_id'
end
