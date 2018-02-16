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
		m = Meeting.new(user_id: @user.id, date_time: date_time, location_type: location_type, nickname: nickname, relay_number: @relay_number)
		m.save
		["Send this link to #{nickname}:","http://meetable.ai/invite?m=#{m.share_code}"]
	end

	def relay
		inviter = User.find(@user.meetings.where(:relay_number => @relay_number).last)
		invitee = User.find(Meeting.where(:relay_number => @relay_number, :invitee_id => @user.id))
		if inviter
			to_number = invitee.phone_number
			message = "[Paul]: #{@wit[:_text]}"
		elsif 
			to_number = inviter.phone_number
			meeting = @user.meetings.where(:relay_number => @relay_number).last
			message = "[#{meeting.nickname}]: #{@wit[:_text]}"
		end

		Message.new(from: ENV['TWILIO_NUMBER'], to: to_number, message: message)

		connections = User.find(@user.meetings.pluck(:invitee_id))
		connections.each do |c|
			if c.first_name == to
				return ["You're message was sent to #{c.first_name}"]
			end
		end
			
		return ["I couldn't find anyone named #{to} for you. Let's try again."]
	end
end