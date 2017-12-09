class AddInviteeNameToMeeting < ActiveRecord::Migration[5.0]
  def change
  	add_column :meetings, :datetime, :datetime 
  end
end
