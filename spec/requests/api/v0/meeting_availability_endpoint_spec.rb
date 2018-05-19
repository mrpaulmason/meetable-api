require 'rails_helper'

describe "MeetingAvailbilityEndpoint API" do

  it 'sends availability information to API' do
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


    # API receives request indicating user wants to set an availability window
    current_time = Time.now
    params = {
              "start_time": current_time.strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
              "start_buffer": 1.5,
              "end_buffer": 1
    }
    post "/meetings/#{mp.plan_code}/time", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT': 'application/json' }

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    # check that meeting availability recorded properly
    meet_avail = MeetingAvailability.joins(:meeting_participant).where(
                                                                        :start_buffer => 1.5,
                                                                        :end_buffer => 1,
                                                                        :active=> true,
                                                                        :meeting_participants => {
                                                                                  :meeting => m,
                                                                                  :user => user
                                                                        }
    )
    expect(meet_avail.length).to eq(1)
    expect(meet_avail[0].start_time.utc.to_s).to eq(current_time.utc.to_s)


    # ensure that meeting availability not registered for user2
    meet_avail_count = MeetingAvailability.joins(:meeting_participant).where(:meeting_participants => { :meeting => m, :user => user2}).count
    expect(meet_avail_count).to eq(0)

    # API receives request indicating user wants to update availability
    current_time2 = current_time + 2.hours
    params = {
              "start_time": current_time2.strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
              "start_buffer": 0.5,
              "end_buffer": 2
    }
    post "/meetings/#{mp.plan_code}/time", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT': 'application/json' }

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    # check that previous meeting time no longer active
    meet_avail_count = MeetingAvailability.joins(:meeting_participant).where(
                                                                        :start_buffer => 1.5,
                                                                        :end_buffer => 1,
                                                                        :active=> true,
                                                                        :meeting_participants => {
                                                                                  :meeting => m,
                                                                                  :user => user
                                                                        }
    ).count
    expect(meet_avail_count).to eq(0)

    # check that previous meeting time inactive
    meet_avail_count = MeetingAvailability.joins(:meeting_participant).where(
                                                                        :start_time => current_time.strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
                                                                        :start_buffer => 1.5,
                                                                        :end_buffer => 1,
                                                                        :active => false,
                                                                        :meeting_participants => {
                                                                                  :meeting => m,
                                                                                  :user => user
                                                                        }
    ).count
    expect(meet_avail_count).to eq(1)

    # check that new meeting time active
    meet_avail_count = MeetingAvailability.joins(:meeting_participant).where(
                                                                        :start_time => current_time2.strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
                                                                        :start_buffer => 0.5,
                                                                        :end_buffer => 2,
                                                                        :active => true,
                                                                        :meeting_participants => {
                                                                                  :meeting => m,
                                                                                  :user => user
                                                                        }
    ).count
    expect(meet_avail_count).to eq(1)

    # API receives request indicating user2 wants to provide an availability window
    current_time3 = current_time + 1.hours
    params = {
      "start_time": current_time3.strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
      "start_buffer": 1,
      "end_buffer": 1
    }
    post "/meetings/#{mp2.plan_code}/time", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT': 'application/json' }

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    # check that meeting availability recorded for user2
    meet_avail = MeetingAvailability.joins(:meeting_participant).where(
                                                                        :start_buffer => 1,
                                                                        :end_buffer => 1,
                                                                        :active => true,
                                                                        :meeting_participants => {
                                                                                  :meeting => m,
                                                                                  :user => user2
                                                                        }
    )
    expect(meet_avail.length).to eq(1)
    expect(meet_avail[0].start_time.utc.to_s).to eq(current_time3.utc.to_s)

    # ensure that 3 meeting availability records present
    expect(MeetingAvailability.all.count).to eq(3)
  end
end
