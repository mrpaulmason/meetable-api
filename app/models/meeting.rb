class Meeting < ApplicationRecord
	validates :share_code, uniqueness: true
	before_create :generate_share_code
	before_save :clean

	def generate_share_code
		self.share_code = SecureRandom.hex(3)
	end

	def clean
		self.date = self.date.strip unless self.date.nil?
		self.time = self.time.strip unless self.time.nil?
		self.location_type = self.location_type.strip unless self.location_type.nil?
	end
end
