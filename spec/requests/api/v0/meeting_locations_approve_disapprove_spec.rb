require 'rails_helper'

describe "PlacesLocationFilter API" do

  fixtures :places

  it 'toggles approval/disapproval of locations for meeting' do
    user = User.find_or_create_by(phone_number: "+18888888888")
    Relay.create([{ :number => '+10000000000', :active => true }, { :number => '+10000000001', :active => true }])
    relay_number = Meeting.choose_relay
    m = Meeting.create(date_time: DateTime.now, location_type: "bar", nickname: "user1", relay_number: relay_number)
    m.participants << user
    m.save()
    MeetingParticipant.where(:user => user, :meeting => m).update_all(:creator => true)
    mp = MeetingParticipant.find_by(:user => user, :meeting => m)
    user2 = User.find_or_create_by(phone_number: "+18888888881")
    m.participants << user2
    m.save()
    mp2 = MeetingParticipant.find_by(:user => user2, :meeting => m)

    place = Place.all.first

    # API receives request indicating user wants to approve a location
    params = {}
    post "/meetings/#{mp.plan_code}/locations/#{place.id}", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT': 'application/json' }

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    # check that meeting location approved by user
    meet_loc_count = MeetingLocation.where(:place => place, :meeting => m, :user => user).count
    expect(meet_loc_count).to eq(1)

    # ensure that meeting location approval not registered for user2
    meet_loc_count = MeetingLocation.where(:place => place, :meeting => m, :user => user2).count
    expect(meet_loc_count).to eq(0)

    # API receives request indicating user wants to disapprove location
    params = {}
    post "/meetings/#{mp.plan_code}/locations/#{place.id}", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT': 'application/json' }

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    # check that no meeting location approvals present for this place
    meet_loc_count = MeetingLocation.where(:place => place, :meeting => m).count
    expect(meet_loc_count).to eq(0)

    # API receives request indicating user2 wants to approve location
    params = {}
    post "/meetings/#{mp2.plan_code}/locations/#{place.id}", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT': 'application/json' }

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    # check that meeting location approved by user2
    meet_loc_count = MeetingLocation.where(:place => place, :meeting => m, :user => user2).count
    expect(meet_loc_count).to eq(1)

    # ensure that meeting location approval not registered for user
    meet_loc_count = MeetingLocation.where(:place => place, :meeting => m, :user => user).count
    expect(meet_loc_count).to eq(0)
  end
end
