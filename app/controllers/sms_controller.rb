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
		no_ref_msg = {:status => 400, :message => 'Could not find referal'}
		render :json => no_ref_msg unless Meeting.find_by_share_code(params['ref']) 
		
		no_user_msg = {:status => 400, :message => 'Could not create user'}
		render :json => no_user_msg unless params.has_key?("phone_number") 
		
		user = User.find_or_create_by(phone_number: params["phone_number"])
		meeting = Meeting.find_by_share_code(params['ref'])
		meeting.invitee_id = user.id
		msg = {:status => 200}
		render :json => msg
	end
end
