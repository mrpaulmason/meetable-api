class MeetingController < ApplicationController
	def accept
        render :json => APIResponse.response(type: "invalid_referral_code") and return unless meeting = Meeting.find_by_share_code(params[:id])
        render :json => APIResponse.response(type: "invalid_phone_number") and return unless user = User.find_or_create_by(phone_number: "+1#{params['phone_number']}")

				# create a new meeting if the meeting already has an invitee_id
				# this was originally introduced as a Y Combinator hack
				# it allows a meeting relay number to be re-used if that becomes useful
        meeting = if meeting.invitee_id.nil? then meeting else Meeting.new(user_id: meeting.user.id, date_time: meeting.date_time, location_type: meeting.location_type, nickname: "") end

        meeting.invitee_id = user.id

        if meeting.save
            begin
								message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "#{meeting.nickname} submitted number")
                message.save

                message = Message.new(to: user.phone_number, from: meeting.relay_number, message: "Welcome to Meetable! Use this number to text Paul. Or text PAUSE / STOP anytime. Save this contact and add color to your inbox!")
                message.save

								# relay is passed into vcard generating url in order to ensure that vCard contains relay for THIS meeting
                message = Message.new(to: user.phone_number, from: meeting.relay_number, media_url: "https://meetable-api.herokuapp.com/vcard/#{meeting.relay_number}")
                message.save

                message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "#{meeting.nickname} received welcome msgs")
                message.save

								# [Paul] hardcoded here but will need to be updated when meeting invititation capabilities are more widely opened
                message = Message.new(to: user.phone_number, from: meeting.relay_number, message: "[Paul] Hi #{meeting.nickname.split(" ").first.capitalize}")
                message.save

								# This message should no longer be sent once meeting invitation capability more widely available
								message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "Hi msg sent to #{meeting.nickname.split(" ").first.capitalize} (relay #{Meeting.where(:relay_number => Relay.where(active: true).pluck(:number)).distinct.count})")
								message.save
            rescue => e
                puts e.message
                render :json => APIResponse.response(type: "twilio_error") and return
            end

            render :json => APIResponse.response(type: "ok") and return
        end

        render :json => APIResponse.response(type: "error")
    end

    def confirm
				# confirm method built before introduction of shortstop which implicitly indicates authorized use of the number
				# leaving the code in case it becomes useful at some point in the future
        render :json => APIResponse.response(type: "invalid_referral_code") and return unless meeting = Meeting.find_by_share_code(params[:id])
        render :json => APIResponse.response(type: "invalid_confirmation_code") and return unless meeting.confirmation_code == params[:confirmation_code].to_i
        render :json => APIResponse.response(type: "invalid_phone_number") and return unless user = User.find(meeting.invitee_id)

        if meeting.confirmation_code == params[:confirmation_code].to_i
            begin
                message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "#{meeting.nickname} submitted number")
                message.save

                message = Message.new(to: user.phone_number, from: meeting.relay_number, message: "Welcome to Meetable!")
                message.save

                message = Message.new(to: user.phone_number, from: meeting.relay_number, media_url: "https://meetable-api.herokuapp.com/vcard/#{meeting.relay_number}")
                message.save

                message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "#{meeting.nickname} received welcome msgs")
                message.save

                message = Message.new(to: user.phone_number, from: meeting.relay_number, message: "[Paul] Hey #{meeting.nickname.split(" ").first.capitalize}", send_at: Time.now + 30.seconds)
                message.save

                message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "Hi msg sent", send_at: Time.now + 31.seconds)
                message.save
            rescue => e
                puts e.message
                render :json => APIResponse.response(type: "twilio_error") and return
            end

            render :json => APIResponse.response(type: "ok") and return
        end

        render :json => APIResponse.response(type: "error")
    end

		def genrelay
				# accepts share code from endpoint and returns the relay number associated to the meeting
			  render :json => APIResponse.response(type: "invalid_referral_code") and return unless meeting = Meeting.find_by_share_code(params[:id])
				begin
					render :json => {'relay_number': meeting.relay_number.sub("+1","")}
				rescue => e
					render :json => APIResponse.response(type: "error")
				end
		end
end
