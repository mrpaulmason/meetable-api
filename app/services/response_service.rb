class ResponseService
	def initialize(user:, wit:, relay_number:)
		@user = user
		@wit = wit
		@relay_number = relay_number
	end

	def new_meeting
		hotline = @relay_number
		nickname = @wit[:_text].split(".").first[0..-1].strip.capitalize
		location_type = @wit[:_text].split(" ").last
		date_time = @wit[:entities].has_key?(:datetime) ? @wit[:entities][:datetime].first[:value] : nil

		relay_number = Meeting.choose_relay
		m = Meeting.new(user_id: @user.id, date_time: date_time, location_type: location_type, nickname: nickname, relay_number: relay_number)
		m.save
		r = Message.new(from: hotline, to: @user.phone_number, message: "Send this link to #{nickname}:")
		r.save
		sleep(0.5)
		t = Message.new(from: hotline, to: @user.phone_number, message: "https://meetable.ai/#{m.share_code}")
		t.save
	end

	def relay
		inviter_meeting = Meeting.where(:relay_number => @relay_number, :user_id => @user.id).last
		invitee_meeting = Meeting.where(:relay_number => @relay_number, :invitee_id => @user.id).last

		if inviter_meeting
			invitee = User.find(inviter_meeting.invitee_id)
			to_number = invitee.phone_number
			relay_number = @relay_number
			if @wit[:_text].start_with?("/")
				message = " #{@wit[:_text]}"
			else
				message = "[Paul] #{@wit[:_text]}"
			end
		elsif invitee_meeting
			inviter = User.find(invitee_meeting.user_id)
			to_number = inviter.phone_number
			relay_number = @relay_number
			if @wit[:_text] == @wit[:_text].upcase
				message = "🐚 #{@wit[:_text]}"
			else
				message = "[#{invitee_meeting.nickname}] #{@wit[:_text]}"
			end
		else
			# this is an accept request from shortstop
			m = Meeting.find_by(:relay_number => @relay_number)
			Meeting.accept(m, @user)
			to_number = m.user.phone_number
			relay_number = m.relay_number
			message = "[#{m.nickname}] #{@wit[:_text]}"
		end

		r = Message.new(from: relay_number, to: to_number, message: message)
		r.save
	end

	def administrate
		if @wit[:_text].include?("release")
			relay = Relay.find_by_number(@relay_number)
			relay.released = true
			relay.save

			active_relays = Relay.where(active: true, released: false).pluck(:number)
			active_meeting_count = Meeting.where(:relay_number => active_relays).count
			nevnum_count = active_relays.count - active_meeting_count
			r = Message.new(from: relay.number, to: @user.phone_number, message: "You have successfully released this relay. #{nevnum_count} nevernums remaining")
			r.save
		end
	end
end
