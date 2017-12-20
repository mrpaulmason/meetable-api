class MeetingController < ApplicationController
	def accept 
        unless meeting = Meeting.find_by_share_code(params[:id])
            render :json => APIResponse.response(type: "invalid_referral_code") 
            return 
        end
        
        unless params.has_key?("phone_number") 
            render :json => APIResponse.response(type: "invalid_phone_number")
            return
        end
        
        user = User.find_or_create_by(phone_number: params["phone_number"])
        meeting.invitee_id = user.id
        
        if meeting.save
            begin
                client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
                client.messages.create(from: ENV['TWILIO_NUMBER'], to: user.phone_number, body: "Welcome to Meetable!")
                client.messages.create(from: ENV['TWILIO_NUMBER'], to: user.phone_number, media_url: "https://meetable-api.herokuapp.com/vcard")
            rescue
                render :json => render APIResponse.response(type: "error")
                return
            end

            render :json => render APIResponse.response(type: "ok")
            return
        end

        render APIResponse.response(type: "error")
    end
end
