class CreateWaitlists < ActiveRecord::Migration[5.0]
  def change
    create_table :waitlists do |t|
      t.string :email
      t.string :survey, array: true

      t.timestamps
    end
  end
end
