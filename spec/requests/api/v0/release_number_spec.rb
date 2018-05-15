require 'rails_helper'

describe "ReleaseNumberCommand API" do
  it 'sends release command to API, relay is updated as released, and messages sent' do
    # create a dummy user
    user = User.find_or_create_by(phone_number: '+18888888888')
    # create a set of relay numbers
    Relay.create(
              [
                { :number => '+11111111111', :active => true },
                { :number => '+12222222222', :active => true },
                { :number => '+13333333333', :active => true },
                { :number => '+14444444444', :active => true }
              ]
    )
    release_number = '+12222222222'
    m = Meeting.create(date_time: DateTime.now, location_type: "bar", nickname: "user1", relay_number: '+11111111111')
    m.participants << user
    mp = MeetingParticipant.where(:user => user, :meeting => m).update_all(:creator => true)

    # assert that all relay numbers have a released flag value set to false
    expect(Relay.where(released: false).count).to eq(4)

    # create a message with one of the relay numbers where the 'From' number
    # is the dummy user's number. Set the 'To' number to one of the relay numbers
    # the body of the message should be //RELEASE
    params = { "From": "#{user.phone_number}", "To": release_number, "Body": "//release" }
    post "/sms/reply", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT': 'application/json' }

    # assert that the chosen relay number's "released" flag is set to true
    expect(Relay.where(released: true, number: release_number).count).to eq(1)

    # assert that the "released" flag of remaining relay numbers are still false
    expect(Relay.where(released:false).count).to eq(3)

    # assert that one message created with confirmation and nevnum remaining status
    expect(Message.all.count).to eq(1)

    nevernum_count = Relay.where(active: true, released: false).count - Meeting.where(relay_number: Relay.where(active: true, released: false).pluck(:number)).distinct.count
    msgs = Message.where(to: '+18888888888', from: release_number, message: "You have successfully released this relay. #{nevernum_count} nevernums remaining")
    expect(msgs.count).to eq(1)
  end
end
