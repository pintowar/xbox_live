module XboxLive

  # Each GamesPage tracks the data contianed in an Xbox Live "Compare
  # Games" page.  This can be used to determine which games a player has
  # played, and their score and number of achievements acquired in each
  # game.
  #
  # Example: http://live.xbox.com/en-US/Activity?compareTo=someone
  class GamesPage

    attr_accessor :gamertag, :page, :url, :updated_at, :gamertile_large,
      :gamerscore, :progress, :games, :data


    # Create a new GamesPage for the provided gamertag. Retrieve the
    # html game compare page from the Xbox Live web site for analysis.
    def initialize(gamertag)
      @gamertag = gamertag
      refresh
    end


    # Force a reload of the GamesPage data from the Xbox Live web site.
    def refresh
      url = XboxLive.options[:url_prefix] + '/en-US/Activity?' +
        Mechanize::Util.build_query_string(compareTo: @gamertag)
      @page = XboxLive::Scraper::get_page(url)
      return false if page.nil?

      @url = url
      @updated_at = Time.now
      @data = retrieve_game_data
      @gamertile_large = find_gamertile_large
      @gamerscore = find_gamerscore
      @progress = find_progress
      @games = find_games

      return true
    end

    private

    # POST to retrieve the JSON data about games that have been played
    def retrieve_game_data
      if token = find_request_verification_token
        url = XboxLive.options[:url_prefix] + '/en-US/Activity/Summary?' +
          Mechanize::Util.build_query_string(compareTo: @gamertag)
        page = XboxLive::Scraper::post_page(url, '__RequestVerificationToken' => token)
      end
      JSON.parse(page.body)['Data']
    end

    # Find the RequestVerificationToken
    def find_request_verification_token
      token_block = @page.at('input[name=__RequestVerificationToken]')
      token_block ? token_block.get_attribute('value') : nil
    end

    # Find and return the player's large gamertile url from the Games data
    def find_gamertile_large
      player = @data['Players'].find { |p| p['Gamertag'] == @gamertag }
      player ? player['Gamerpic'] : nil
    end

    # Find and return the player's gamerscore from the Games page
    def find_gamerscore
      player = @data['Players'].find { |p| p['Gamertag'] == @gamertag }
      player ? player['Gamerscore'] : nil
    end

    # Find and return the player's game progress statistic from the Games page
    def find_progress
      player = @data['Players'].find { |p| p['Gamertag'] == @gamertag }
      player ? player['PercentComplete'] : nil
    end

    # Find and return an array of hashes containing information about each
    # game the player has played.
    def find_games
      games = @data['Games'].collect do |game|
        gi = GameInfo.new(gamertag, game['Id'])
        gi.name = game['Name']
        gi.tile = game['BoxArt']
        gi.total_points = game['PossibleScore']
        gi.total_achievements = game['PossibleAchievements']
        gi.unlocked_points = game['Progress'][@gamertag]['Score']
        gi.unlocked_achievements = game['Progress'][@gamertag]['Achievements']
        gi.last_played = game['Progress'][@gamertag]['LastPlayed']
        gi
      end
      return games
    end

  end

end
