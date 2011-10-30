module XboxLive

  # Each AchievementsPage tracks and makes available the data contianed
  # in an Xbox Live "Compare Game" page.  This can be used to determine
  # which achievements a player has unlocked in a game.
  #
  # Example: http://live.xbox.com/en-US/GameCenter/Achievements?titleId=1161890128&compareTo=someone
  class AchievementsPage

    attr_accessor :gamertag, :game_id, :page, :url, :updated_at, :achievements

    private_class_method :new


    # Rather than letting the caller instantiate new instances
    # themselves, creating duplicative instances, callers should use the
    # AchievementsPage.find() class method which will return an existing
    # AchievementsPage for the specified gamertag, or will instantiate a
    # new instance if necessary.
    #
    # See http://juixe.com/techknow/index.php/2007/01/22/ruby-class-tutorial/
    def self.find(gamertag, game_id)
      achievements_page = ObjectSpace.each_object(XboxLive::AchievementsPage).find { |p| p.gamertag == gamertag and p.game_id == game_id }
      if achievements_page.nil?
        achievements_page = new(gamertag, game_id)
      end
      return achievements_page
    end


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
    # Ensure a minimal amount of time has gone by before doing a refresh.
    def refresh
      return false if @updated_at and Time.now - @updated_at < XboxLive.options[:refresh_age]
      url = XboxLive.options[:url_prefix] + '/en-US/GameCenter/Achievements?' +
        Mechanize::Util.build_query_string(titleId: @game_id, compareTo: @gamertag)
      @page = XboxLive::Scraper::get_page url
      return false if page.nil?

      @url = url
      @updated_at = Time.now
      @achievements = find_achievements

      return true
    end


    private


    # Find and return an array of hashes containing information about each
    # achievement the player has unlocked.
    def find_achievements
      achievements = @page.search('div.SpaceItem').collect do |item|
        data = Hash.new
        data[:ach_id] = item.at('div.AchievementInfo').attribute('id').value
        data[:name] = item.at('div.AchievementInfo h3').inner_html.strip
        data[:description] = item.at('div.AchievementInfo p').inner_html.strip
        data[:tile] = item.at('div.AchievementInfo img').get_attribute('src')
        if item.at('div.grid-4').at('div.NotAchieved')
          data[:points] = data[:unlocked_at] = nil
        else
          data[:points] = item.at('div.GamerScore').inner_html[/\d+/].to_i
          html = item.at('div.AchievementCompareBlock').inner_html
          if html.include? "unlocked on"
            data[:unlocked_on] = html.match(/unlocked on (.*)/)[1].strip
          else
            data[:unlocked_on] = "12/01/2006"
          end
        end
        data
      end
      return achievements
    end

    # These methods are used to find data about a specific game within
    # an HTML "div.lineitem" block

    # Find and return the number of points the player has achieved in
    # this game so far.
    def lineitem_player_points(lineitem)
      score_block = lineitem.at('div.grid-4 div.GamerScore')
      score_block ? score_block.inner_html.to_i : nil
    end

    # Find and return the total number of points available in this game.
    def lineitem_game_points(lineitem)
      score_block = lineitem.at('div.grid-4 div.GamerScore')
      score_block ? score_block.inner_html.match(/\/ (\d+)/)[1].to_i : nil
    end

    # Find and return the number of achievements the player has unlocked in
    # this game so far.
    def lineitem_player_achievements(lineitem)
      score_block = lineitem.at('div.grid-4 div.Achievement')
      score_block ? score_block.inner_html.to_i : nil
    end

    # Find and return the total number of achievements available in this game.
    def lineitem_game_achievements(lineitem)
      score_block = lineitem.at('div.grid-4 div.Achievement')
      score_block ? score_block.inner_html.match(/\/ (\d+)/)[1].to_i : nil
    end

  end

end
