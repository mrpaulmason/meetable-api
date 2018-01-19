class Place < ApplicationRecord
	validates :google_id, uniqueness: true
end
