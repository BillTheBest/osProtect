class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer     :user_id
      t.boolean     :for_all_users, default: false # true = created by an admin for all users
      t.boolean     :run_status, default: false # enabled or disabled
      t.boolean     :auto_run, default: false
      t.string      :name
      t.boolean     :include_summary
      t.text        :report_criteria
      t.string      :report_criteria_as_string
      t.timestamps
    end
  end
end
