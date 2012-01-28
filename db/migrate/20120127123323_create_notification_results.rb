class CreateNotificationResults < ActiveRecord::Migration
  def change
    create_table :notification_results do |t|
      t.integer     :notification_id
      t.text        :result_ids
      t.text        :messages
      t.text        :stats
      t.timestamps
    end
  end
end
