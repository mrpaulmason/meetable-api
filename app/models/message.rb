class Message < ApplicationRecord
	attribute :send_at, :datetime, default: Time.now
	attribute :sent, :boolean, default: false
end
