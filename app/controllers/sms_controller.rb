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
		when 'relay'
			message = params["Body"]
			responses = response_service.relay(
				to: message.split(" ").second, 
				message: message.split(" ")[3...message.split(" ").length].join(" ")
			)
		else
			#responses ["Hello there, thanks for texting me. Your number is #{from_number}."]
			message = params["Body"]
			responses = response_service.relay(
				to: message.split(" ").second, 
				message: message.split(" ")[3...message.split(" ").length].join(" ")
			)
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
		no_user_msg = {:status => 400, :message => 'Sorry, please provide a valid phone number.'}
		error_msg = {:status => 400, :message => 'There was an error, please try again'}
		ok_msg = {:status => 200, :message => "OK"}

		unless meeting = Meeting.find_by_share_code(params['ref']) 
			render :json => no_ref_msg 
			return 
		end
		
		unless user = User.find_or_create_by(phone_number: params["phone_number"])
			render :json => no_user_msg
			return
		end

		user.first_name = meeting.nickname 
		user.save
		
		meeting.invitee_id = user.id
		if meeting.save
			client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
			client.messages.create(from: ENV['TWILIO_NUMBER'], to: user.phone_number, body: "Welcome to Meetable!")
			client.messages.create(from: ENV['TWILIO_NUMBER'], to: user.phone_number, media_url: "https://meetable-api.herokuapp.com/vcard")
			render :json => ok_msg
		else
			render :json => error_msg
		end
	end
end
