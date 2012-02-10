class NotificationResult < ActiveRecord::Base
  belongs_to :notification

  # this captures the actual criteria used to create this result, which may
  # not be the same as the notify_criteria currently set in the Notification
  # as users may alter/edit a notification:
  serialize :notify_criteria_for_this_result, NotificationCriteria

  serialize :result_ids

  attr_accessible :priority_ids, :minimum_matches, :attacker_ips, :target_ips
  attr_reader :priority_ids, :minimum_matches, :attacker_ips, :target_ips
end
