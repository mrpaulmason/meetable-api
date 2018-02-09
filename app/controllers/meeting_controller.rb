class MeetingController < ApplicationController
	def accept  
       	render :json => APIResponse.response(type: "invalid_referral_code") and return unless meeting = Meeting.find_by_share_code(params[:id])
        render :json => APIResponse.response(type: "invalid_phone_number") and return unless user = User.find_or_create_by(phone_number: params["phone_number"])
        
        meeting = Meeting.find_by_share_code(params[:id])
        meeting.invitee_id = user.id
        
        if meeting.save
            begin
                send_message(to: meeting.user.phone_number, from: meeting.relay_number, message: "🤖: #{meeting.nickname} submitted number")
                send_message(to: user.phone_number, from: meeting.relay_number, message: "🤖: Welcome to Meetable!")
                send_message(to: user.phone_number, from: meeting.relay_number, media_url: "https://meetable-api.herokuapp.com/vcard")
                send_message(to: meeting.user.phone_number, from: meeting.relay_number, message: "🤖: #{meeting.nickname} received welcome msgs")
                send_message(to: user.phone_number, from: meeting.relay_number, message: "[Paul]: Hey #{meeting.nickname.split(" ").first.capitalize}", delay: 30.0)
                send_message(to: meeting.user.phone_number, from: meeting.relay_number, message: "🤖: Hi msg sent", delay: 31.0)
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

    def send_message(to:, from:, message: nil, media_url: nil, delay: 0.0)
        sleep delay
        client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
        if message
            client.messages.create(from: from, to: to, body: message)
        elsif media_url
            client.messages.create(from: from, to: to, media_url: media_url)
        end
    end
end
