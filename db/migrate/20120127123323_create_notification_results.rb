class CreateNotificationResults < ActiveRecord::Migration
  def change
    create_table :notification_results do |t|
      t.references  :user
      t.integer     :notification_id
      # we dup this attribute from Notification, coz the user may alter the criteria after this result was created:
      t.text        :notify_criteria_for_this_result
      t.boolean     :email_sent, default: false
      t.datetime    :events_timestamped_from
      t.datetime    :events_timestamped_to
      t.integer     :total_matches
      t.text        :result_ids
      t.text        :messages
      t.timestamps
    end
  end
end
