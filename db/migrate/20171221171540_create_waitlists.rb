class CreateWaitlists < ActiveRecord::Migration[5.0]
  def change
    create_table :waitlists do |t|
      t.string :email
      t.array :survey

      t.timestamps
    end
  end
end
