require 'twilio-ruby'

class SmsController < ApplicationController
	def reply
		user = User.find_or_create_by(phone_number: params["From"])
		message = params["Body"]
		wit = Wit.message(message: message)
		intent = wit[:entities].has_key?(:intent) ? wit[:entities][:intent].first[:value] : nil
		response_service = ResponseService.new(user: user, wit: wit, relay_number: params["To"])
		responses = []
		if message.start_with?("\"","'","`")
			responses = response_service.relay
		else
			case intent 
			when 'new'
				responses = response_service.new_meeting
			end
		end
		
		responses.each do |response|
			message = Message.new(to: user.phone_number, from: params["To"], message: "🤖: #{response}")
			message.save
		end
	end
end
