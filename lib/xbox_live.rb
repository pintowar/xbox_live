require 'mechanize'
require 'xbox_live/version'
require 'xbox_live/scraper'
require 'xbox_live/game_info'
require 'xbox_live/achievement_info'
require 'xbox_live/profile_page'
require 'xbox_live/games_page'
require 'xbox_live/achievements_page'

module XboxLive

  # Provides configurability.
  def self.options
    @options ||= {
      :username => nil,
      :password => nil,
      :refresh_age => 600,  # data will be re-fetched if older than X seconds
      :url_prefix => 'http://live.xbox.com'
    }
  end

end
