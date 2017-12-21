class FixSurveyField < ActiveRecord::Migration[5.0]
  def change
  	add_column :waitlists, :survey, :json
  end
end
