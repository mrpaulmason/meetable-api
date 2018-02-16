class AddSentToMessage < ActiveRecord::Migration[5.0]
  def change
  	add_column :messages, :sent, :boolean
  end
end
