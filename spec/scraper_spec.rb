require 'spec_helper'

describe XboxLive::Scraper do

  describe "#get_page" do
    it "should return a Mechanize::Page instance" do
      @page = XboxLive::Scraper.get_page('http://live.xbox.com/en-US/MyXbox/Profile?gamertag=major%20nelson')
      @page.should_not be_nil
      @page.class.should == Mechanize::Page
    end
  end
end
