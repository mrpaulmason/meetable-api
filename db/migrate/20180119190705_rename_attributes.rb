class RenameAttributes < ActiveRecord::Migration[5.0]
  def change
  	remove_column :places, :attributes
  	add_column :places, :types, :string, array:true, default: []
  end
end
