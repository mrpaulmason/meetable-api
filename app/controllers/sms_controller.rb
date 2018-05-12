require 'twilio-ruby'

class SmsController < ApplicationController
	def reply
		user = User.find_or_create_by(phone_number: params["From"])
		message = params["Body"]
		# creating wit.ai message, essentially wrapping the message in wit
		# object to enable the functionality of the library to be used within
		# response service object
		wit = Wit.message(message: message)
		intent = wit[:entities].has_key?(:intent) ? wit[:entities][:intent].first[:value] : nil
		response_service = ResponseService.new(user: user, wit: wit, relay_number: params["To"])
		responses = []
		if message.start_with?("+")
			# '+' is the symbol indicating request is to create new meeting
			response_service.new_meeting
		elsif message.start_with?("//")
			# '//' is the symbol indicating that request is to perform admin function
			response_service.administrate
		else
			# any other message is handled by relay function
			response_service.relay
		end
	end
end
