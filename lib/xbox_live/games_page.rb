module XboxLive

  # Each GamesPage tracks and makes available the data contianed in an Xbox
  # Live "Compare Games" page.  This can be used to determine which games
  # a player has played, and their score and number of achievements acquired
  # in each game.
  #
  # Example: http://live.xbox.com/en-US/GameCenter?compareTo=someone
  class GamesPage

    attr_accessor :gamertag, :page, :url, :updated_at, :gamertile_large

    private_class_method :new


    # Rather than letting the caller instantiate new instances themselves,
    # creating duplicative instances, callers should use the GamesPage.find()
    # class method which will return an existing GamesPage for the specified
    # gamertag, or will instantiate a new instance if necessary.
    #
    # See http://juixe.com/techknow/index.php/2007/01/22/ruby-class-tutorial/
    def self.find(gamertag)
      games_page = ObjectSpace.each_object(XboxLive::GamesPage).find { |p| p.gamertag == gamertag }
      if games_page.nil?
        games_page = new(gamertag)
      end
      return games_page
    end


    # Create a new GamesPage for the provided gamertag. Retrieve the
    # html game compare page from the Xbox Live web site for analysis. To
    # prevent multiple instances for the same gamertag, this method is
    # marked as private. The GamesPage.find() method should be used
    # to find an existing instance or create a new one if needed.
    def initialize(gamertag)
      @gamertag = gamertag
      refresh
    end


    # Force a reload of the GamesPage data from the Xbox Live web site.
    # Ensure a minimal amount of time has gone by before doing a refresh.
    def refresh
      return false if @updated_at and Time.now - @updated_at < XboxLive.options[:refresh_age]
      url = XboxLive.options[:url_prefix] + '/en-US/GameCenter?' +
        Mechanize::Util.build_query_string(compareTo: @gamertag)
      @page = XboxLive::Scraper::get_page url
      return false if page.nil?

      @url = url
      @updated_at = Time.now
      @gamertile_large = find_gamertile_large
      @gamerscore = find_gamerscore
      @progess = find_progress
      @games = find_games

      return true
    end

    private

    # Find and return the player's large gamertile url from the Games page
    def find_gamertile_large
      score_block = @page.at('div.HeaderArea div.grid-4').at('div.ScoreBlock')
      score_block ? score_block.at('img').get_attribute('src') : nil
    end

    # Find and return the player's gamerscore from the Games page
    def find_gamerscore
      score_block = @page.at('div.HeaderArea div.ScoreBlock')
      score_block ? score_block.at('div.GamerScore').inner_html.to_i : nil
    end

    # Find and return the player's game progress statistic from the Games page
    def find_progress
      progress_block = @page.at('div.HeaderArea div.ProgressLabel')
      progress_block ? progress_block.inner_html.strip : nil
    end

    # Find and return an array of hashes containing information about each
    # game the player has played.
    def find_games
      games = @page.search('div.LineItem').collect do |lineitem|
        # Only analyze this game if the player has played it
        if lineitem.at('div.grid-4').at('div.NotPlayed').nil?
          data = Hash.new
          data[:game_name] = lineitem_game_name(lineitem)
          data[:game_id] = lineitem_game_id(lineitem)
          data[:gametile] = lineitem_game_tile(lineitem)
          data[:player_points] = lineitem_player_points(lineitem)
          data[:game_points] = lineitem_game_points(lineitem)
          data[:player_achievements] = lineitem_player_achievements(lineitem)
          data[:game_achievements] = lineitem_game_achievements(lineitem)
        end
        data
      end
      return games
    end

    # These methods are used to find data about a specific game within
    # an HTML "div.lineitem" block

    # Find and return the game name from an HTML lineitem block
    def lineitem_game_name(lineitem)
      name_block = lineitem.at('h3 a')
      name_block ? name_block.inner_html.strip : nil
    end

    # Find and return the Xbox Live web site game id number from an
    # HTML lineitem block
    def lineitem_game_id(lineitem)
      comparison_url = lineitem_game_comparison_url(lineitem)
      comparison_url ? comparison_url.match(/titleId=(\d+)/)[1] : nil
    end

    # Find and return the Xbox Live web site game id number from an
    # HTML lineitem block
    def lineitem_game_tile(lineitem)
      tile_block = lineitem.at('img.BoxShot')
      tile_block ? tile_block.get_attribute('src') : nil
    end

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
