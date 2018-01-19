class ChangeToGoogleId < ActiveRecord::Migration[5.0]
  def change
  	remove_column :places, :chij
  	add_column :places, :google_id, :string
  end
end
