class MeetingParticipant < ApplicationRecord
  belongs_to :meeting
  belongs_to :user

  has_many :meeting_locations
  has_many :locations, :through => :meeting_locations, :source => :place

  validates :plan_code, uniqueness: true
	before_create :generate_plan_code

  def generate_plan_code
		self.plan_code = SecureRandom.hex(3)
		# keep generating share codes if generated code already exists in meeting table
		while MeetingParticipant.where("plan_code = ?", self.plan_code).count != 0
			self.plan_code = SecureRandom.hex(3)
		end
	end

end
