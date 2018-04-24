require 'rails_helper'

describe "ReleaseNumberCommand API" do
  it 'sends phone number and message to relay as acceptance of meeting' do
    # create a dummy user
    # create a set of relay numbers
    # assert that all relay numbers have a released flag value set to false
    # create a message with one of the relay numbers where the 'From' number
    # is the dummy user's number. Set the 'To' number to one of the relay numbers
    # the body of the message should be //RELEASE
    # assert that the chosen relay number's "release" flag is set to true
    # assert that the "release" flag of remaining relay numbers are still false

    # assert that two messages are created which have the following information:
    # 1) Message stating "You have successfully released [NUMBER]"
    # 2) Message stating "x nevernums remaining"

  end
end
