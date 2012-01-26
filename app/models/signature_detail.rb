class SignatureDetail < ActiveRecord::Base
  # set_table_name 'signature' # deprecated in rails 3.2.0, instead do:
  self.table_name = 'signature'
  self.pluralize_table_names = false
  # set_primary_key 'sig_id' # deprecated in rails 3.2.0, instead do:
  self.primary_key = 'sig_id'
  alias_attribute :id, :sig_id

  has_many :events, foreign_key: 'signature'
  has_many :signature_references, :foreign_key => 'sig_id'
  belongs_to :signature_class, class_name: "SignatureClass", foreign_key: 'sig_class_id', primary_key: 'sig_class_id'

  def self.selections(user)
    signatures = self.select('sig_id, sig_name').order("sig_name asc").all
  end

  def self.priorities(user)
    # priorities = self.select('distinct sig_priority, sig_priority').where("sig_priority IS NOT NULL").order("sig_priority asc")
    # ... or using Arel to avoid hard-coding db specific SQL:
    priorities = self.select('distinct sig_priority, sig_priority').where(self.arel_table[:sig_priority].not_eq(nil)).order("sig_priority asc")
  end
end
