class Place < ApplicationRecord
	validates :google_id, uniqueness: true

	has_many :meeting_locations
end
