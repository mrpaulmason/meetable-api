require 'rufus/scheduler'

scheduler = Rufus::Scheduler.new
scheduler.every '2s' do
	Messages.send
end