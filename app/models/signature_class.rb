class SignatureClass < ActiveRecord::Base
  set_table_name 'sig_class'
  self.pluralize_table_names = false
  set_primary_key 'sig_class_id'
  alias_attribute :id, :sig_class_id

  has_many :signature_details, :foreign_key => 'sig_class_id'
end
