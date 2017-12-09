class AddDateTimeToMeetings < ActiveRecord::Migration[5.0]
  def change
    add_column :meetings, :date_time, :datetime
  end
end
