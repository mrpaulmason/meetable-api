class User < ApplicationRecord
	validates :phone_number, uniqueness: true
	validates :phone_number, :presence => true
end
