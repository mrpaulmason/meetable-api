class MeetingController < ApplicationController
	def accept  
       	render :json => APIResponse.response(type: "invalid_referral_code") and return unless meeting = Meeting.find_by_share_code(params[:id])
        render :json => APIResponse.response(type: "invalid_phone_number") and return unless user = User.find_or_create_by(phone_number: params["phone_number"])
        
        meeting = Meeting.find_by_share_code(params[:id])
        meeting.invitee_id = user.id
        
        if meeting.save
            begin
                message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "#{meeting.nickname} submitted number")
                message.save

                message = Message.new(to: user.phone_number, from: meeting.relay_number, message: "Welcome to Meetable!")
                message.save

                message = Message.new(to: user.phone_number, from: meeting.relay_number, media_url: "https://meetable-api.herokuapp.com/vcard")
                message.save

                message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "#{meeting.nickname} received welcome msgs")
                message.save

                message = Message.new(to: user.phone_number, from: meeting.relay_number, message: "[Paul] Hey #{meeting.nickname.split(" ").first.capitalize}", send_at: Time.now + 30.seconds)
                message.save

                message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "Hi msg sent", send_at: Time.now + 31.seconds)
                message.save
            rescue => e
                render :json => APIResponse.response(type: "twilio_error") and return
            end

            render :json => APIResponse.response(type: "ok") and return
        end

        render :json => APIResponse.response(type: "error")
    end

    def locations
        render :json => APIResponse.response(type: "invalid_referral_code") and return unless meeting = Meeting.find_by_share_code(params[:id])
        render :json => Places.list(category: params[:category])
    end
end
