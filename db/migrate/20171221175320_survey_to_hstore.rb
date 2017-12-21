class SurveyToHstore < ActiveRecord::Migration[5.0]
  def change
  	remove_column :waitlists, :survey
  end
end
