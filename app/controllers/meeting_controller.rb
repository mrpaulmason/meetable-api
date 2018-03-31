class MeetingController < ApplicationController
	def accept
        render :json => APIResponse.response(type: "invalid_referral_code") and return unless meeting = Meeting.find_by_share_code(params[:id])
        render :json => APIResponse.response(type: "invalid_phone_number") and return unless user = User.find_or_create_by(phone_number: "+1#{params['phone_number']}")

        meeting = Meeting.find_by_share_code(params[:id])
        meeting.invitee_id = user.id

				meeting.relay_number = Meeting.choose_relay initiator: meeting.user, acceptor: user

        if meeting.save
            begin
                #message = Message.new(to: user.phone_number, from: meeting.relay_number, message: "Your Meetable verification code is: #{meeting.confirmation_code}")
                #message.save
								message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "#{meeting.nickname} submitted number")
                message.save

                message = Message.new(to: user.phone_number, from: meeting.relay_number, message: "Welcome to Meetable! Use this number to text Paul. Or text PAUSE / STOP anytime. Save this contact and add color to your inbox!")
                message.save

                message = Message.new(to: user.phone_number, from: meeting.relay_number, media_url: "https://meetable-api.herokuapp.com/vcard/#{meeting.relay_number}")
                message.save

                message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "#{meeting.nickname} received welcome msgs")
                message.save

                message = Message.new(to: user.phone_number, from: meeting.relay_number, message: "[Paul] Hi #{meeting.nickname.split(" ").first.capitalize}", send_at: Time.now + 30.seconds)
                message.save

                message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "Hi msg sent to #{meeting.nickname.split(" ").first.capitalize}", send_at: Time.now + 31.seconds)
                message.save
            rescue => e
                puts e.message
                render :json => APIResponse.response(type: "twilio_error") and return
            end

            render :json => APIResponse.response(type: "ok") and return
        end

        render :json => APIResponse.response(type: "error")
    end

    def confirm
        render :json => APIResponse.response(type: "invalid_referral_code") and return unless meeting = Meeting.find_by_share_code(params[:id])
        render :json => APIResponse.response(type: "invalid_confirmation_code") and return unless meeting.confirmation_code == params[:confirmation_code].to_i
        render :json => APIResponse.response(type: "invalid_phone_number") and return unless user = User.find(meeting.invitee_id)

        if meeting.confirmation_code == params[:confirmation_code].to_i
            begin
                message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "#{meeting.nickname} submitted number")
                message.save

                message = Message.new(to: user.phone_number, from: meeting.relay_number, message: "Welcome to Meetable!")
                message.save

                message = Message.new(to: user.phone_number, from: meeting.relay_number, media_url: "https://meetable-api.herokuapp.com/vcard/#{meeting.relay_number}")
                message.save

                message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "#{meeting.nickname} received welcome msgs")
                message.save

                message = Message.new(to: user.phone_number, from: meeting.relay_number, message: "[Paul] Hey #{meeting.nickname.split(" ").first.capitalize}", send_at: Time.now + 30.seconds)
                message.save

                message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "Hi msg sent", send_at: Time.now + 31.seconds)
                message.save
            rescue => e
                puts e.message
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
