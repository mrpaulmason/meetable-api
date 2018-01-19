class AddAttributesAndCategoriesToPlaces < ActiveRecord::Migration[5.0]
  def change
  	add_column :places, :attributes, :string, array:true, default: []
  	add_column :places, :categories, :string, array:true, default: []
  end
end
