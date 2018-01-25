namespace :data do
	task :places => :environment do
		Places.parse
	end
end