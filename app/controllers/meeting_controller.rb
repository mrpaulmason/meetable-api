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

		def update_locations
				render :json => APIResponse.response(type: "invalid_plan_code") and return unless meeting_participant = MeetingParticipant.find_by_plan_code(params[:plan_code])
				render :json => APIResponse.response(type: "invalid_location_id") and return unless place = Place.find(params[:place_id])
				if MeetingLocation.where(:meeting_participant => meeting_participant, :place => place).count == 1
						MeetingLocation.find_by(:meeting_participant => meeting_participant, :place => place).destroy
				else
						MeetingLocation.create(:meeting_participant => meeting_participant, :place => place)
				end
				render :json => APIResponse.response(type: "ok") and return
		end

		def update_availability
				render :json => APIResponse.response(type: "invalid_plan_code") and return unless meeting_participant = MeetingParticipant.find_by_plan_code(params[:plan_code])
				MeetingAvailability.where(:meeting_participant => meeting_participant, :active => true).update_all(:active => false)
				MeetingAvailability.create(:meeting_participant => meeting_participant, :start_time => params[:start_time], :start_buffer => params[:start_buffer], :end_buffer => params[:end_buffer], :active => true)
				render :json => APIResponse.response(type: "ok") and return
		end

		def record_view
				render :json => APIResponse.response(type: "invalid_plan_code") and return unless meeting_participant = MeetingParticipant.find_by_plan_code(params[:plan_code])
				MeetingView.create(:meeting_participant => meeting_participant, :view_time => Time.now)
				render :json => APIResponse.response(type: "ok") and return
		end

		def record_share
				render :json => APIResponse.response(type: "invalid_plan_code") and return unless meeting_participant = MeetingParticipant.find_by_plan_code(params[:plan_code])
				MeetingShare.create(:meeting_participant => meeting_participant, :share_time => Time.now)
				render :json => APIResponse.response(type: "ok") and return
		end
end
