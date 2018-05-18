class CreateMeetingLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :meeting_locations do |t|
      t.references :meeting_participant, foreign_key: true
      t.references :place, foreign_key: true

      t.timestamps
    end
  end
end
