class CleanMeetingTable < ActiveRecord::Migration[5.0]
  def change
  	remove_column :meetings, :date
  	remove_column :meetings, :time
  end
end
