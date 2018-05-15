class Meeting < ApplicationRecord
	validates :share_code, uniqueness: true
	before_create :generate_share_code
	before_save :clean
	has_many :meeting_participants
	has_many :participants, :through => :meeting_participants, :source => :user

	def generate_share_code
		self.share_code = SecureRandom.hex(3)
		# keep generating share codes if generated code already exists in meeting table
		while Meeting.where("share_code = ?", self.share_code).count != 0
			self.share_code = SecureRandom.hex(3)
		end
		self.confirmation_code = 6.times.map { rand(1..9) }.join.to_i
	end

	def clean
		self.location_type = self.location_type.strip unless self.location_type.nil?
	end

	def self.choose_relay
		# baton implementation
		# find an active and unreleased relay number that hasn't been assigned
		# to any meeting
		Relay.where(active: true, released: false).each do |relay|
			return relay.number unless Meeting.where(
																	:relay_number => relay.number
			).count != 0
		end
		# if we reach this point, a new number needs to be acquired
		# return last number for now
		return Relay.where(active: true, released: false).last.number
	end

	def self.accept(in_meeting, user)
		# create a new meeting if the meeting already has an invitee_id
		# originally introduced as a Y Combinator hack
		# it allows a meeting relay number to be re-used if that becomes useful
		meeting = if in_meeting.participants.length == 1 then in_meeting else Meeting.new(date_time: in_meeting.date_time, location_type: in_meeting.location_type, nickname: "") end
		if meeting.participants.length == 0
				# new meeting created
				# need to update meeting participants and creator for this new meeting
				meeting.participants << in_meeting.participants[0]
				MeetingParticipant.where(:meeting => m).update_all(:creator => true)
		end
		meeting.participants << user

		if meeting.save
			begin
				message = Message.new(to: meeting.participants[0].phone_number, from: meeting.relay_number, message: "#{meeting.nickname} submitted number")
				message.save

				message = Message.new(to: user.phone_number, from: meeting.relay_number, message: "Welcome to Meetable! Use this number to text Paul. Or text PAUSE / STOP anytime. Save this contact and add color to your inbox!")
				message.save

				message = Message.new(to: user.phone_number, from: meeting.relay_number, media_url: "https://meetable-api.herokuapp.com/vcard/#{meeting.relay_number}")
				message.save

				message = Message.new(to: meeting.participants[0].phone_number, from: meeting.relay_number, message: "#{meeting.nickname} received welcome msgs")
				message.save

				message = Message.new(to: user.phone_number, from: meeting.relay_number, message: "[Paul] Hi #{meeting.nickname.split(" ").first.capitalize}")
				message.save

				message = Message.new(to: meeting.participants[0].phone_number, from: meeting.relay_number, message: "Hi msg sent to #{meeting.nickname.split(" ").first.capitalize} (relay #{Relay.where("number = ?", meeting.relay_number).first.id - 1} of #{Relay.where("active = ?", true).count})")
				message.save

				return true
			rescue => e
				puts e.message
			end
		end

		return false
	end
end
