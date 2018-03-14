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
		r = Message.new(from: ENV['TWILIO_NUMBER'], to: @user.phone_number, message: "Send this link to #{nickname}:")
		r.save
		t = Message.new(from: ENV['TWILIO_NUMBER'], to: @user.phone_number, message: "http://meetable.ai/invite?m=#{m.share_code}")
		t.save
	end

	def relay
		inviter_meeting = Meeting.where(:relay_number => @relay_number, :user_id => @user.id).last
		invitee_meeting = Meeting.where(:relay_number => @relay_number, :invitee_id => @user.id).last
		
		if inviter_meeting
			invitee = User.find(inviter_meeting.invitee_id)
			to_number = invitee.phone_number
			message = "[Paul] #{@wit[:_text]}"
		elsif invitee_meeting
			inviter = User.find(invitee_meeting.user_id)
			to_number = inviter.phone_number
			if @wit[:_text] == @wit[:_text].upcase
				message = "🐚 #{@wit[:_text]}"
			else
				message = "[#{invitee_meeting.nickname}] #{@wit[:_text]}"
			end
		end

		r = Message.new(from: ENV['TWILIO_NUMBER'], to: to_number, message: message)
		r.save
	end
end