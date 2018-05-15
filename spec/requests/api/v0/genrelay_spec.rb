require 'rails_helper'

# following a tutorial on API testing: http://matthewlehner.net/rails-api-testing-guidelines/
# spec/requests/api/v0/genrelay_spec.rb
describe "RelayService API" do
  it 'sends request for relay number' do
    user = User.find_or_create_by(phone_number: "+18888888888")
    Relay.create(
              [
                { :number => '+13477652900', :active => true },
                { :number => '+13478975600', :active => true },
                { :number => '+13477676800', :active => true }
              ]
    )
    m = Meeting.create(date_time: DateTime.now, location_type: "bar2", nickname: "user1", relay_number: '+13477652900')
    m.participants << user
    mp = MeetingParticipant.where(:user => user, :meeting => m).update_all(:creator => true)
    share_code = m.share_code

    get "/meetings/#{m.share_code}/genrelay"

    m = Meeting.find_by_share_code(share_code)

    expect(m.relay_number).to eq('+13477652900')

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    # check to make sure relay number is correct
    #expect(Phonelib.valid? json['relay_number']).to eq(true)
    expect(json['relay_number']).to eq('3477652900')
  end
end
