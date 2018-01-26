class AddNicknameToUsers < ActiveRecord::Migration[5.0]
  def change
  	add_column :meetings, :nickname, :string
  end
end
