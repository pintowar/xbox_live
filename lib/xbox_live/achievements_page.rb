module XboxLive

  # Each AchievementsPage tracks and makes available the data contianed
  # in an Xbox Live "Compare Game" page.  This can be used to determine
  # which achievements a player has unlocked in a game.
  #
  # Example: http://live.xbox.com/en-US/GameCenter/Achievements?titleId=1161890128&compareTo=someone
  class AchievementsPage

    attr_accessor :gamertag, :game_id, :page, :url, :updated_at, :achievements

    # Create a new AchievementsPage for the provided gamertag. Retrieve
    # the html compare achievements page from the Xbox Live web site for
    # analysis. To prevent multiple instances for the same gamertag,
    # this method is marked as private. The AchievementsPage.find()
    # method should be used to find an existing instance or create a new
    # one if needed.
    def initialize(gamertag, game_id)
      @gamertag = gamertag
      @game_id = game_id
      refresh
    end


    # Force a reload of the AchievementsPage data from the Xbox Live web site.
    def refresh
      url = XboxLive.options[:url_prefix] + '/en-US/GameCenter/Achievements?' +
        Mechanize::Util.build_query_string(titleId: @game_id, compareTo: @gamertag)
      @page = XboxLive::Scraper::get_page url
      return false if page.nil?

      @url = url
      @updated_at = Time.now
      @achievements = find_achievements

      true
    end


    private

    # Find and return an array of hashes containing information about each
    # achievement the player has unlocked.
    def find_achievements
      achievements = @page.search('div.SpaceItem').collect do |item|
        ai = AchievementInfo.new(gamertag, game_id, find_achievement_id_from_spaceitem(item))
        ai.name        = find_achievement_name_from_spaceitem(item)
        ai.description = find_achievement_description_from_spaceitem(item)
        ai.tile        = find_achievement_tile_from_spaceitem(item)
        if achievement_unlocked?(item)
          ai.points      = find_achievement_points_from_spaceitem(item)
          ai.unlocked_on = find_achievement_unlock_date_from_spaceitem(item)
        end
        ai
      end
      achievements
    end

    # These methods are used to find data about a specific achievement within
    # an HTML "div.SpaceItem" block.

    def achievement_unlocked?(item)
      item.at('div.grid-4').at('div.NotAchieved').nil?
    end

    def find_achievement_id_from_spaceitem(item)
      item.at('div.AchievementInfo').attribute('id').value
    end

    def find_achievement_name_from_spaceitem(item)
      item.at('div.AchievementInfo h3').inner_html.strip
    end

    def find_achievement_description_from_spaceitem(item)
      item.at('div.AchievementInfo p').inner_html.strip
    end

    def find_achievement_tile_from_spaceitem(item)
      item.at('div.AchievementInfo img').get_attribute('src')
    end

    def find_achievement_points_from_spaceitem(item)
      item.at('div.GamerScore').inner_html[/\d+/].to_i
    end

    # Some achievements don't list an unlock date (for example, if the
    # unlock happened when the player was not logged into Xbox Live).
    # For those, we supply a generic, old date.
    def find_achievement_unlock_date_from_spaceitem(item)
      html = item.at('div.AchievementCompareBlock').inner_html
      if html.include? "unlocked on"
        return html.match(/unlocked on (.*)/)[1].strip
      else
        return "12/01/2006"
      end
    end

  end

end
