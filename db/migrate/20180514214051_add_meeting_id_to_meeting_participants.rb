class AddMeetingIdToMeetingParticipants < ActiveRecord::Migration[5.0]
  def change
    add_column :meeting_participants, :meeting_id, :integer
    add_index :meeting_participants, :meeting_id
  end
end
