require 'rails_helper'

describe "AcceptOnReplyService API" do
  it 'sends phone number and message to relay as acceptance of meeting' do
    user = User.find_or_create_by(phone_number: "+18888888888")
    Relay.create([{ :number => '+10000000000', :active => true }, { :number => '+10000000001', :active => true }])
    relay_number = Meeting.choose_relay
    m = Meeting.create(date_time: DateTime.now, location_type: "bar", nickname: "user1", relay_number: relay_number)
    m.participants << user
    MeetingParticipant.where(:user => user, :meeting => m).update_all(:creator => true)
    share_code = m.share_code
    invitee = User.find_or_create_by(phone_number: "+17777777777")
    params = { "From": "#{invitee.phone_number}", "To": relay_number, "Body": "This is cool!" }
    post "/sms/reply", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT': 'application/json' }

    m = Meeting.find_by_share_code(share_code)

    expect(m.participants).to include(user)
    expect(m.participants).to include(invitee)
    expect(m.relay_number).to eq(relay_number)

    msgs = Message.where(:to => user.phone_number, :from => m.relay_number, :message => "[#{m.nickname}] This is cool!")

    expect(msgs.count).to eq(1)

  end
end
