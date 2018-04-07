class Meeting < ApplicationRecord
	validates :share_code, uniqueness: true
	before_create :generate_share_code
	before_save :clean
	belongs_to :user

	def generate_share_code
		# loop until unique share code generated
		self.share_code = SecureRandom.hex(3)
		while Meeting.where("share_code = ?", self.share_code)
			self.share_code = SecureRandom.hex(3)
		self.confirmation_code = 6.times.map { rand(1..9) }.join.to_i
	end

	def clean
		self.location_type = self.location_type.strip unless self.location_type.nil?
	end

	def self.choose_relay initiator:, acceptor:
		Relay.where("active = ?", true).each do |relay|
			return relay.number unless Meeting.where(:relay_number => relay.number, :user_id => [initiator.id, acceptor.id])
								.or(Meeting.where(:relay_number => relay.number, :invitee_id => [initiator.id, acceptor.id])
			).count != 0
		end
		# if we reach this point, a new number needs to be acquired
		# return last number for now
		return Relay.where("active = ?", true).last.number
	end
end
