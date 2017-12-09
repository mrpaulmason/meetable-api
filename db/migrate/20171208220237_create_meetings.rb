class CreateMeetings < ActiveRecord::Migration[5.0]
  def change
    create_table :meetings do |t|
      t.integer :user_id
      t.string :time
      t.date :date
      t.string :location_type
      t.string :share_code

      t.timestamps
    end
  end
end
