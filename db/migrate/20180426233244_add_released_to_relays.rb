class AddReleasedToRelays < ActiveRecord::Migration[5.0]
  def change
    add_column :relays, :released, :boolean, default: false
  end
end
