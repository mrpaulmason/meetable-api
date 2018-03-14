require 'twilio-ruby'

class SmsController < ApplicationController
	def reply
		user = User.find_or_create_by(phone_number: params["From"])
		message = params["Body"]
		wit = Wit.message(message: message)
		intent = wit[:entities].has_key?(:intent) ? wit[:entities][:intent].first[:value] : nil
		response_service = ResponseService.new(user: user, wit: wit, relay_number: params["To"])
		responses = []
		if message.start_with?("/")
			response_service.new_meeting
		else
			response_service.relay
		end
	end
end
