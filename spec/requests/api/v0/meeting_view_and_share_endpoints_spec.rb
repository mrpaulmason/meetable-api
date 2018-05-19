require 'rails_helper'

describe "MeetingViewsAndShares APIs" do

  it 'sends view and share information to API' do
    user = User.find_or_create_by(phone_number: "+18888888888")
    Relay.create([{ :number => '+10000000000', :active => true }, { :number => '+10000000001', :active => true }])
    relay_number = Meeting.choose_relay
    m = Meeting.create(date_time: DateTime.now, location_type: "bar", nickname: "user1", relay_number: relay_number)
    m.participants << user
    m.save()
    MeetingParticipant.where(:user => user, :meeting => m).update_all(:creator => true)
    mp = MeetingParticipant.find_by(:user => user, :meeting => m)

    # check that no meeting view recorded for participant
    view_count = MeetingView.joins(:meeting_participant).where(
                                                            :meeting_participants => {
                                                                      :meeting => m,
                                                                      :user => user
                                                            }
    ).count
    expect(view_count).to eq(0)

    params = {}
    post "/meetings/#{mp.plan_code}/view", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT': 'application/json' }

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    # check that meeting view recorded for participant
    view_count = MeetingView.joins(:meeting_participant).where(
                                                            :meeting_participants => {
                                                                      :meeting => m,
                                                                      :user => user
                                                            }
    ).count
    expect(view_count).to eq(1)

    # check that no meeting share recorded
    share_count = MeetingShare.joins(:meeting_participant).where(
                                                      :meeting_participants => {
                                                                :meeting => m,
                                                                :user => user
                                                      }
    ).count
    expect(share_count).to eq(0)

    params = {}
    post "/meetings/#{mp.plan_code}/share", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT': 'application/json' }

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    # check that meeting share recorded
    share_count = MeetingShare.joins(:meeting_participant).where(
                                                      :meeting_participants => {
                                                                :meeting => m,
                                                                :user => user
                                                      }
    ).count
    expect(share_count).to eq(1)

  end
end
