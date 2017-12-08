class User < ApplicationRecord
	validates :phone_number, uniqueness: true
end
