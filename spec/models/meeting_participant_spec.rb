require 'rails_helper'

RSpec.describe MeetingParticipant, type: :model do
  it 'can create a new meeting and add participants to it' do
    user = User.find_or_create_by(phone_number: "+18888888888")
    m = Meeting.create(user_id: user.id, date_time: DateTime.now, location_type: "bar", nickname: "user1")
    user1 = User.find_or_create_by(phone_number: "+18888888881")
    user2 = User.find_or_create_by(phone_number: "+18888888882")
    m.save()
    m.participants << user1
    m.participants << user2
  end
end
