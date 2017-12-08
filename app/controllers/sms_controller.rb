require 'twilio-ruby'

class SmsController < ApplicationController
	def reply
		message_body = params["Body"]
		from_number = params["From"]
		client = Twilio::REST::Client.new 'AC159ea454d65ec3c5d443d7da8d4b5644', '301b4fd074ff17b541a42962725bab3c'
		sms = client.messages.create(
			from: '+16467599030',
			to: from_number,
			body: "Hello there, thanks for texting me. Your number is #{from_number}."
		)
	end
end
