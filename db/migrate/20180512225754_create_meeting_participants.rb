class CreateMeetingParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :meeting_participants do |t|

      t.timestamps
    end
  end
end
