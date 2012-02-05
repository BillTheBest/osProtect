class CreateNotificationResults < ActiveRecord::Migration
  def change
    create_table :notification_results do |t|
      t.integer     :notification_id
      t.boolean     :email_sent,              default: false
      t.datetime    :events_timestamped_from
      t.datetime    :events_timestamped_to
      t.integer     :total_matches
      t.text        :result_ids
      t.text        :messages
      t.timestamps
    end
  end
end
