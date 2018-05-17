class MeetingLocation < ApplicationRecord
  belongs_to :meeting_participant
  belongs_to :place
end
