module XboxLive

  # Each AchievementsPage tracks and makes available the data contianed
  # in an Xbox Live "Compare Game" page.  This can be used to determine
  # which achievements a player has unlocked in a game.
  #
  # Example: http://live.xbox.com/en-US/Activity/Details?titleId=1161890128&compareTo=someone
  class AchievementsPage

    attr_accessor :gamertag, :game_id, :page, :url, :updated_at, :achievements, :data

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
      url = XboxLive.options[:url_prefix] + '/en-US/Activity/Details?' +
        Mechanize::Util.build_query_string(titleId: @game_id, compareTo: @gamertag)
      @page = XboxLive::Scraper::get_page url
      return false if page.nil?

      @url = url
      @updated_at = Time.now
      @data = retrieve_achievement_data
      @gamertag = find_gamertag
      @achievements = find_achievements

      true
    end


    private

    # POST to retrieve the JSON data about achievements for this game
    def retrieve_achievement_data
      data = @page.body.match(/\(routes\.activity\.details\.load,(.*?\);)/)[1][0..-3]
      JSON.parse(data)
    end

    # Find the gamertag, in case the caps/lowercase are different than
    # what was provided.
    def find_gamertag
      player = @data['Players'].find { |p| p['Gamertag'].casecmp(@gamertag) == 0 }
      player ? player['Gamertag'] : nil
    end

    # Find and return an array of hashes containing information about each
    # achievement the player has unlocked.
    def find_achievements
      achievements = @data['Achievements'].collect do |ach|
        ai = AchievementInfo.new(gamertag, @game_id, ach['Id'])
        ai.name        = ach['Name']
        ai.description = ach['Description']
        ai.tile        = ach['TileUrl']
        if unlocked?(ach)
          ai.points      = ach['Score']
          # TODO: Refactor this mess
          time_field = ach['EarnDates'][@gamertag]['EarnedOn'].match(/Date\((\d+)/)
          ai.unlocked_at = Time.at(time_field[1].to_i / 1000) if time_field
        end
        ai
      end
      achievements
    end

    # Has the player unlocked this achievement?
    def unlocked?(ach)
      !!ach['EarnDates'][@gamertag]
    end

  end

end
