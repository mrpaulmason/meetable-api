class ResponseService
	def initialize(user:, wit:, relay_number:)
		@user = user
		@wit = wit
		@relay_number = relay_number
	end

	def new_meeting
		nickname = @wit[:_text].split(".").first.capitalize
		location_type = @wit[:_text].split(" ").last
		date_time = @wit[:entities].has_key?(:datetime) ? @wit[:entities][:datetime].first[:value] : nil
		m = Meeting.new(user_id: @user.id, date_time: date_time, location_type: location_type, nickname: nickname, relay_number: relay_number)
		m.save
		["Send this link to #{nickname}:","http://meetable.ai/invite?m=#{m.share_code}"]
	end

	def relay(to:, message:)
		connections = User.find(@user.meetings.pluck(:invitee_id))
		connections.each do |c|
			if c.first_name == to
				client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
				client.messages.create(from: ENV['TWILIO_NUMBER'], to: c.phone_number, body: "Hey #{c.first_name}, #{@user.first_name} says:")
				client.messages.create(from: ENV['TWILIO_NUMBER'], to: c.phone_number, body: message)

				return ["You're message was sent to #{c.first_name}"]
			end
		end
			
		return ["I couldn't find anyone named #{to} for you. Let's try again."]
	end
end