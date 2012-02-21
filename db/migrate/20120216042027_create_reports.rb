class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer     :group_id
      t.integer     :user_id
      t.boolean     :for_all_users, default: false # true=created by an admin for all users
      # report types:
      #   1 - EventsReport with optional summary(pulse) page ... EventsPdf
      #   2 - IncidentsReport with description+resolution and their events ... IncidentsPdf
      t.integer     :report_type, default: 1
      t.boolean     :run_status, default: false # enabled or disabled
      t.boolean     :auto_run, default: false
      t.boolean     :include_summary, default: false
      t.string      :auto_run_at # d=daily(previous day), w=weekly(previous week), m=monthly(previous month)
      t.string      :name
      t.text        :report_criteria
      t.string      :report_criteria_as_string
      t.timestamps
    end
  end
end
