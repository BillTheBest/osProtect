class Reference < ActiveRecord::Base
  set_table_name 'reference'
  self.pluralize_table_names = false
  set_primary_key 'ref_id'
  alias_attribute :id, :ref_id

  belongs_to :signature_reference, :class_name => "SignatureReference", :foreign_key => 'ref_id', :primary_key => 'ref_id'
  belongs_to :reference_system, :class_name => "ReferenceSystem", :foreign_key => 'ref_system_id', :primary_key => 'ref_system_id'
end
