class NotificationResult < ActiveRecord::Base
  belongs_to :notification

  serialize :result_ids
end
