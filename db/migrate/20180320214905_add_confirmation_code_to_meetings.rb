class AddConfirmationCodeToMeetings < ActiveRecord::Migration[5.0]
  def change
  	add_column :meetings, :confirmation_code, :integer
  end
end
