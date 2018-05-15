class ResponseService
	def initialize(user:, wit:, relay_number:)
		@user = user
		@wit = wit
		@relay_number = relay_number
	end

	def new_meeting
		hotline = @relay_number
		# meeting nickname is taken to be all text through first '.' in message
		nickname = @wit[:_text].split(".").first[0..-1].strip.capitalize
		# assumes new meeting message contains two main components
		# 1) location as last token before first period
		# 2) invitee name before first period
		location_type = @wit[:_text].split(" ").last
		# wit can recognize date time information from message if included
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
		# attempting to lookup meeting based on relay number and which role
		# associated user fulfills on meeting
		inviter_meeting = Meeting.where(:relay_number => @relay_number, :user_id => @user.id).last
		invitee_meeting = Meeting.joins(:participants).where(:relay_number => @relay_number, meeting_participants: {user_id: @user.id}).last

		if inviter_meeting
			# message is from the inviter
			invitee = User.find(inviter_meeting.invitee_id)
			to_number = invitee.phone_number
			relay_number = @relay_number
			if @wit[:_text].start_with?("/")
				# send message as if it is coming from bot
				message = " #{@wit[:_text]}"
			else
				# send message as if it is coming from inviter (hard-coded as Paul for now)
				message = "[Paul] #{@wit[:_text]}"
			end
		elsif invitee_meeting
			# message is from the invitee
			inviter = User.find(invitee_meeting.user_id)
			to_number = inviter.phone_number
			relay_number = @relay_number
			if @wit[:_text] == @wit[:_text].upcase
				# all uppercase message is communication with Meetable (not inviter)
				message = "🐚 #{@wit[:_text]}"
			else
				# send message through to inviter
				message = "[#{invitee_meeting.nickname}] #{@wit[:_text]}"
			end
		else
			# this is an accept request from shortstop
			# the relay number is all that is needed to find the meeting
			m = Meeting.find_by(:relay_number => @relay_number)

			if Meeting.accept(m, @user)
				to_number = m.user.phone_number
				relay_number = m.relay_number
				message = "[#{m.nickname}] #{@wit[:_text]}"
			else
				# don't send a message if the accept process failed
				return
			end
		end

		r = Message.new(from: relay_number, to: to_number, message: message)
		r.save
	end

	def administrate
		# administrative functionality processed through messages are
		# handled here
		if @wit[:_text].include?("release")
			# //release command sent as message for this relay number
			relay = Relay.find_by_number(@relay_number)
			# set relay to released so that record no longer used
			relay.released = true
			relay.save

			# providing updated stats on nevernums available
			active_relays = Relay.where(active: true, released: false).pluck(:number)
			active_meeting_count = Meeting.where(:relay_number => active_relays).count
			nevnum_count = active_relays.count - active_meeting_count
			r = Message.new(from: relay.number, to: @user.phone_number, message: "You have successfully released this relay. #{nevnum_count} nevernums remaining")
			r.save
		end
	end
end
