class CreateMeetingLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :meeting_locations do |t|

      t.timestamps
    end
  end
end
