class Messages 
	def self.send
		messages_to_send = Message.where("sent = ? AND send_at >= ?", false, Time.now)
		puts "queue started"
		puts messages_to_send
		messages_to_send.each do |m|
			m.sent = true
			m.save
		end
		messages_to_send.each do |m|
	        if m.message
	            client.messages.create(from: m.from, to: m.to, body: m.message)
	        elsif m.media_url
	            client.messages.create(from: m.from, to: m.to, media_url: m.media_url)
	        end
		end
	end

	def self.client
		Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
	end
end