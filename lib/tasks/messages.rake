require 'rufus-scheduler'

namespace :messages do
	task send: :environment do
		scheduler = Rufus::Scheduler.new
		scheduler.every '2s' do
			Messages.send
		end
		scheduler.join
	end
end