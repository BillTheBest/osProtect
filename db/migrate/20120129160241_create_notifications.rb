class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references  :user
      t.string      :email
      # enabled or disabled:
      t.boolean     :run_status,        default: false
      t.datetime    :last_run
      t.text        :notify_criteria
      t.timestamps
    end
    add_index :notifications, :user_id
  end
end
