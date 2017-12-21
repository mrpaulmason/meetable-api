class SurveyToHstore < ActiveRecord::Migration[5.0]
  def change
  	change_column :waitlists, :survey, :json
  end
end
