class Meeting < ApplicationRecord
	validates :share_code, uniqueness: true
	before_create :generate_share_code
	before_save :clean
	belongs_to :user

	def generate_share_code
		self.share_code = SecureRandom.hex(3)
		while Meeting.where("share_code = ?", self.share_code).count != 0
			self.share_code = SecureRandom.hex(3)
		end
		self.confirmation_code = 6.times.map { rand(1..9) }.join.to_i
	end

	def clean
		self.location_type = self.location_type.strip unless self.location_type.nil?
	end

	def self.choose_relay

		Relay.where("active = ?", true).each do |relay|
			return relay.number unless Meeting.where(
																	:relay_number => relay.number
			).count != 0
		end
		# if we reach this point, a new number needs to be acquired
		# return last number for now
		return Relay.where("active = ?", true).last.number
	end

	def self.accept(meeting, user)
		meeting = if meeting.invitee_id.nil? then meeting else Meeting.new(user_id: meeting.user.id, date_time: meeting.date_time, location_type: meeting.location_type, nickname: "") end

		meeting.invitee_id = user.id

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

						message = Message.new(to: meeting.user.phone_number, from: meeting.relay_number, message: "Hi msg sent to #{meeting.nickname.split(" ").first.capitalize} (relay #{Relay.where("number = ?", meeting.relay_number).first.id - 1} of #{Relay.where("active = ?", true).count})", send_at: Time.now + 31.seconds)
						message.save
				rescue => e
						puts e.message
				end
		end

	end
end
