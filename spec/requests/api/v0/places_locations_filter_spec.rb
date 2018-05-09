require 'rails_helper'

describe "PlacesLocationFilter API" do

  fixtures :places

  it 'receives a filtering request for fixtures' do
    expect(Place.all.count).to eq(10)

    get "/places?category=coffee"

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    expect(json['locations'].length).to eq(3)

    get "/places?category=sports"

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    expect(json['locations'].length).to eq(0)

    get "/places"

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    expect(json['locations'].length).to eq(10)

    get "/places?attribute=Cocktails"

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    expect(json['locations'].length).to eq(6)

    get "/places?category=drinks"

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    expect(json['locations'].length).to eq(7)

    get "/places?category=drinks&attribute=Cocktails"

    json = JSON.parse(response.body)

    # test for the 200 status-code
    expect(response).to be_success

    expect(json['locations'].length).to eq(6)
  end
end
