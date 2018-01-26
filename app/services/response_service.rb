class ResponseService
	def initialize(user:, wit:)
		@user = user
		@wit = wit
	end

	def new_meeting
		name = @wit[:_text].split(" ").second.capitalize
		date_time = @wit[:entities].has_key?(:datetime) ? @wit[:entities][:datetime].first[:value] : nil
		location_type = @wit[:entities].has_key?(:location_type) ? @wit[:entities][:location_type].first[:value] : nil
		if location_type.nil?
			case @wit[:_text].split(" ").last.strip
			when "b"
				location_type = "bar"
			when "c"
				location_type = "coffee shop"
			when "r"
				location_type = "restaurant"
			end
		end
		
		m = Meeting.new(user_id: @user.id, date_time: date_time, location_type: location_type, nickname: name)
		m.save
		["Send this link to #{name}:","http://meetable.ai/invite?m=#{m.share_code}"]
	end

	def relay(to:, message:)
		connections = User.find(user.meetings.pluck(:invitee_id))
		connections.each do |c|
			if c.first_name == to
				client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
				client.messages.create(from: ENV['TWILIO_NUMBER'], to: c.phone_number, body: "Hey #{c.first_name}, #{u.first_name} says:")
				client.messages.create(from: ENV['TWILIO_NUMBER'], to: c.phone_number, body: message)

				return ["You're message was sent to #{c.first_name}"]
			end
		end
			
		return ["I couldn't find anyone named #{to} for you. Let's try again."]
	end
end