class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer     :user_id
      t.string      :name
      t.boolean     :include_summary
      t.text        :report_criteria
      t.string      :report_criteria_as_string
      t.timestamps
    end
  end
end
