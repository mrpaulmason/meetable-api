class Meeting < ApplicationRecord
	validates :share_code, uniqueness: true
	before_create :generate_share_code
	before_save :clean
	belongs_to :user

	def generate_share_code
		self.share_code = SecureRandom.hex(3)
	end

	def clean
		self.location_type = self.location_type.strip unless self.location_type.nil?
	end
end
