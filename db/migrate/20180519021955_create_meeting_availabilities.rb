class CreateMeetingAvailabilities < ActiveRecord::Migration[5.0]
  def change
    create_table :meeting_availabilities do |t|
      t.references :meeting_participant, foreign_key: true
      t.datetime :start_time
      t.float :start_buffer
      t.float :end_buffer
      t.boolean :active

      t.timestamps
    end
  end
end
