class User < ApplicationRecord
	validates :phone_number, uniqueness: true
	validates :phone_number, :presence => true
	has_many :meeting_participants
  has_many :meetings, :through => :meeting_participants
end
