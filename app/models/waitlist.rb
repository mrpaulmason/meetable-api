class Waitlist < ApplicationRecord
	validates :email, uniqueness: true
	validates :email, :presence => true
end
