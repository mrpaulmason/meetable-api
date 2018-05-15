class AddCreatorToMeetingParticipants < ActiveRecord::Migration[5.0]
  def change
    add_column :meeting_participants, :creator, :boolean, :default => false
  end
end
