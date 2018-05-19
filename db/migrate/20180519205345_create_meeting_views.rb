class CreateMeetingViews < ActiveRecord::Migration[5.0]
  def change
    create_table :meeting_views do |t|
      t.references :meeting_participant, foreign_key: true
      t.datetime :view_time

      t.timestamps
    end
  end
end
