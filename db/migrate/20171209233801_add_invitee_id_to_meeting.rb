class AddInviteeIdToMeeting < ActiveRecord::Migration[5.0]
  def change
  	add_column :meetings, :invitee_id, :integer
  end
end
