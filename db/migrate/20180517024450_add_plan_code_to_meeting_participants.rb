class AddPlanCodeToMeetingParticipants < ActiveRecord::Migration[5.0]
  def change
    add_column :meeting_participants, :plan_code, :string
  end
end
