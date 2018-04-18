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

    m = Meeting.create(user_id: user.id, date_time: DateTime.now, location_type: "bar", nickname: "user1", relay_number: '+13477652900')
    share_code = m.share_code

    other_user1 = User.find_or_create_by(phone_number: "+11111111111")
    Meeting.create(user_id: other_user1.id, date_time: DateTime.now, location_type: "bar", nickname: "other_meeting", relay_number: '+13478975600')
    get "/meetings/#{m.share_code}/genrelay"

    m = Meeting.find_by_share_code(share_code)

    expect(m.relay_number).to_not eq('+13477652900')
    expect(m.relay_number).to_not eq('+13478975600')
    expect(m.relay_number).to eq('+13477676800')

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    # check to make sure relay number is correct
    expect(Phonelib.valid? json['relay_number']).to eq(true)
  end
end
