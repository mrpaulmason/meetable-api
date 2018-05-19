class CreateMeetingShares < ActiveRecord::Migration[5.0]
  def change
    create_table :meeting_shares do |t|
      t.references :meeting_participant, foreign_key: true
      t.datetime :share_time

      t.timestamps
    end
  end
end
