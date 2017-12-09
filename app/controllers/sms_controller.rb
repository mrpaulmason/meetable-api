require 'twilio-ruby'

class SmsController < ApplicationController
	def reply
		user = User.find_or_create_by(phone_number: params["From"])
		message = params["Body"]
		response_service = ResponseService.new(user: user, message: message)

		responses = []
		case message.downcase 
		when /\Aqq/
			responses = response_service.new_meeting(name: message.remove("qq").strip)
		else
			responses ["Hello there, thanks for texting me. Your number is #{from_number}."]
		end
		
		client = Twilio::REST::Client.new 'AC159ea454d65ec3c5d443d7da8d4b5644', '301b4fd074ff17b541a42962725bab3c'
		responses.each do |response|
			sms = client.messages.create(
			from: '+16467599030',
			to: user.phone_number,
			body: response
		)
		end
		
	end
end
