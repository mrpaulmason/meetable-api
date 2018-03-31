class CreateRelays < ActiveRecord::Migration[5.0]
  def change
    create_table :relays do |t|
      t.string :number
      t.bollean :active

      t.timestamps
    end
  end
end
