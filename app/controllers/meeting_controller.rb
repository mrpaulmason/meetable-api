class MeetingController < ApplicationController
	def accept
				# this code represents the point at which a meeting request is finalized
				# in the sense that the invitee has provided his or her number
        render :json => APIResponse.response(type: "invalid_referral_code") and return unless meeting = Meeting.find_by_share_code(params[:id])
        render :json => APIResponse.response(type: "invalid_phone_number") and return unless user = User.find_or_create_by(phone_number: "+1#{params['phone_number']}")


        if Meeting.accept(meeting, user)
            render :json => APIResponse.response(type: "ok") and return
        end

        render :json => APIResponse.response(type: "error")
    end

    def confirm
				# confirm method built before introduction of shortstop which implicitly indicates authorized use of the number
				# leaving the code in case it becomes useful at some point in the future
        render :json => APIResponse.response(type: "invalid_referral_code") and return unless meeting = Meeting.find_by_share_code(params[:id])
        render :json => APIResponse.response(type: "invalid_confirmation_code") and return unless meeting.confirmation_code == params[:confirmation_code].to_i
        render :json => APIResponse.response(type: "invalid_phone_number") and return unless meeting.participants.length > 0 and user = User.find(meeting.participants[0])

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
