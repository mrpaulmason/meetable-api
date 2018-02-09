class AddRelayNumberToMeetingAgain < ActiveRecord::Migration[5.0]
  def change
  	add_column :meetings, :relay_number, :string
  end
end
