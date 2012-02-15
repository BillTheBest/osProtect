class CreatePdfs < ActiveRecord::Migration
  def change
    create_table :pdfs do |t|
      t.references  :user
      t.integer     :report_id
      t.string      :path_to_file
      t.string      :file_name
      t.text        :creation_criteria
      t.timestamps
    end
  end
end
