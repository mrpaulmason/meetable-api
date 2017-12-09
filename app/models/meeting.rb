class Meeting < ApplicationRecord
	validates :share_code, uniqueness: true
	before_create :generate_share_code

	def generate_share_code
		self.share_code = SecureRandom.hex(3)
	end
end
