class SurveyToHstore < ActiveRecord::Migration[5.0]
	enable_extension 'hstore' unless extension_enabled?('hstore')
  def change
  	change_column :waitlists, :survey, :hstore
  end
end
