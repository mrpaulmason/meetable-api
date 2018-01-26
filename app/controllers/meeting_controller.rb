class MeetingController < ApplicationController
	def accept  
       	render :json => APIResponse.response(type: "invalid_referral_code") and return unless meeting = Meeting.find_by_share_code(params[:id])
        render :json => APIResponse.response(type: "invalid_phone_number") and return unless user = User.find_or_create_by(phone_number: params["phone_number"])
        
        meeting = Meeting.find_by_share_code(params[:id])
        meeting.invitee_id = user.id
        
        if meeting.save
            begin
                client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
                client.messages.create(from: ENV['TWILIO_NUMBER'], to: user.phone_number, body: "Welcome to Meetable!")
                client.messages.create(from: ENV['TWILIO_NUMBER'], to: user.phone_number, media_url: "https://meetable-api.herokuapp.com/vcard")
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
