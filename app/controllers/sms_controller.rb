require 'twilio-ruby'

class SmsController < ApplicationController
	def reply
		user = User.find_or_create_by(phone_number: params["From"])
		message = params["Body"]
		wit = Wit.message(message: message)
		intent = wit[:entities].has_key?(:intent) ? wit[:entities][:intent].first[:value] : nil
		response_service = ResponseService.new(user: user, wit: wit)
		responses = []
		case intent 
		when 'new'
			responses = response_service.new_meeting
		else
			responses ["Hello there, thanks for texting me. Your number is #{from_number}."]
		end
		client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
		responses.each do |response|
			sms = client.messages.create(
				from: ENV['TWILIO_NUMBER'],
				to: user.phone_number,
				body: response
			)
		end
	end

	def accept 
		no_ref_msg = {:status => 400, :message => 'Sorry, this code is invalid.'}
		unless Meeting.find_by_share_code(params['ref']) 
			render :json => no_ref_msg 
			return 
		end
		
		no_user_msg = {:status => 400, :message => 'Sorry, please provide a valid phone number.'}
		unless params.has_key?("phone_number") 
			render :json => no_user_msg
			return
		end
		
		user = User.find_or_create_by(phone_number: params["phone_number"])
		meeting = Meeting.find_by_share_code(params['ref'])
		meeting.invitee_id = user.id
		if meeting.save
			client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
			client.messages.create(from: ENV['TWILIO_NUMBER'], to: user.phone_number, body: "Welcome to Meetable!")
			client.messages.create(from: ENV['TWILIO_NUMBER'], to: user.phone_number, media_url: "https://meetable-api.herokuapp.com/vcard")
			
			msg = {:status => 200, :message => "OK"}
			render :json => msg
			return
		end

		error_msg = {:status => 400, :message => 'There was an error, please try again'}
		render error_msg
	end
end
