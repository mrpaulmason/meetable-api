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
			send_message(to: user.phone_number, from: params["To"], message: "🤖: #{response}")
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

		unless params["phone_number"] != User.find(Meeting.user_id).phone_number
			render :json => {:status => 400, :message => 'Sorry, please use a different phone number. Did you mean to send this link to someone else?'}
			return 
		end

		user.first_name = meeting.nickname 
		user.save
		
		meeting.invitee_id = user.id
		if meeting.save
			send_message(to: meeting.user.phone_number, from: meeting.relay_number, message: "🤖: #{meeting.nickname} submitted number")
			send_message(to: user.phone_number, from: meeting.relay_number, message: "🤖: Welcome to Meetable!")
			send_message(to: user.phone_number, from: meeting.relay_number, media_url: "https://meetable-api.herokuapp.com/vcard")
			send_message(to: meeting.user.phone_number, from: meeting.relay_number, message: "🤖: #{meeting.nickname} received welcome msgs")
			send_message(to: user.phone_number, from: meeting.relay_number, message: "[Paul]: Hey #{meeting.nickname.split(" ").first.capitalize}", delay: 30.0)
			send_message(to: meeting.user.phone_number, from: meeting.relay_number, message: "🤖: Hi msg sent", delay: 31.0)
			render :json => ok_msg
		else
			render :json => error_msg
		end
	end


	def send_message(to:, from:, message: nil, media_url: nil, delay: 0.0)
		sleep delay
		client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
		if message
			client.messages.create(from: from, to: to, body: message)
		elsif media_url
			client.messages.create(from: from, to: to, media_url: media_url)
		end
	end
end
