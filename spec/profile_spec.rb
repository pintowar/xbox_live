require 'xbox_live/profile'

describe XboxLive::Profile do

  describe "#new" do
    it "should return a Profile instance" do
      @profile = XboxLive::Profile.new('my_gamertag')
      @profile.should_not be_nil
    end
  end
end
