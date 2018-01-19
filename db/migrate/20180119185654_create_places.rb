class CreatePlaces < ActiveRecord::Migration[5.0]
  def change
    create_table :places do |t|
      t.string :chij
      t.string :name
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :zip
      t.string :lat
      t.string :long

      t.timestamps
    end
  end
end
