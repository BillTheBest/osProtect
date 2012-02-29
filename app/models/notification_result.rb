class NotificationResult < ActiveRecord::Base
  belongs_to :notification

  serialize :notify_criteria_for_this_result, ActiveSupport::HashWithIndifferentAccess

  serialize :result_ids, Array
end
