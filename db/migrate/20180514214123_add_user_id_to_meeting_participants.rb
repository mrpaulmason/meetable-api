class AddUserIdToMeetingParticipants < ActiveRecord::Migration[5.0]
  def change
    add_column :meeting_participants, :user_id, :integer
    add_index :meeting_participants, :user_id
  end
end
