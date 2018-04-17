class ResponseService
	def initialize(user:, wit:, relay_number:)
		@user = user
		@wit = wit
		@relay_number = relay_number
	end

	def new_meeting
		nickname = @wit[:_text].split(".").first[0..-1].strip.capitalize
		location_type = @wit[:_text].split(" ").last
		date_time = @wit[:entities].has_key?(:datetime) ? @wit[:entities][:datetime].first[:value] : nil
		# if this relay number is new add it to the relays table
		Relay.find_or_create_by(number: @relay_number) do |relay|
  		relay.active = true
			relay.created_at = DateTime.now
			relay.update_at = DateTime.now
		end
		m = Meeting.new(user_id: @user.id, date_time: date_time, location_type: location_type, nickname: nickname, relay_number: @relay_number)
		m.save
		r = Message.new(from: @relay_number, to: @user.phone_number, message: "Send this link to #{nickname}:")
		r.save
		t = Message.new(from: @relay_number, to: @user.phone_number, message: "https://meetable.ai/#{m.share_code}")
		t.save
	end

	def relay
		inviter_meeting = Meeting.where(:relay_number => @relay_number, :user_id => @user.id).last
		invitee_meeting = Meeting.where(:relay_number => @relay_number, :invitee_id => @user.id).last

		if inviter_meeting
			invitee = User.find(inviter_meeting.invitee_id)
			to_number = invitee.phone_number
			if @wit[:_text].start_with?("/")
				message = " #{@wit[:_text]}"
			else
				message = "[Paul] #{@wit[:_text]}"
			end
		elsif invitee_meeting
			inviter = User.find(invitee_meeting.user_id)
			to_number = inviter.phone_number
			if @wit[:_text] == @wit[:_text].upcase
				message = "🐚 #{@wit[:_text]}"
			else
				message = "[#{invitee_meeting.nickname}] #{@wit[:_text]}"
			end
		end

		r = Message.new(from: @relay_number, to: to_number, message: message)
		r.save
	end
end
