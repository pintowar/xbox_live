module XboxLive

  # Each GamesPage tracks the data contianed in an Xbox Live "Compare
  # Games" page.  This can be used to determine which games a player has
  # played, and their score and number of achievements acquired in each
  # game.
  #
  # Example: http://live.xbox.com/en-US/GameCenter?compareTo=someone
  class GamesPage

    attr_accessor :gamertag, :page, :url, :updated_at, :gamertile_large,
      :gamerscore, :progress, :games


    # Create a new GamesPage for the provided gamertag. Retrieve the
    # html game compare page from the Xbox Live web site for analysis.
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
      games = @page.search('div.LineItem').collect do |item|
        # Only analyze this game if the player has played it
        if item.at('div.grid-4').at('div.NotPlayed').nil?
          gi = GameInfo.new(gamertag, find_game_id_from_lineitem(item))
          gi.name = find_game_name_from_lineitem(item)
          gi.tile = find_game_tile_from_lineitem(item)
          gi.total_points    = find_total_points_from_lineitem(item)
          gi.unlocked_points = find_unlocked_points_from_lineitem(item)
          gi.total_achievements    = find_total_achievements_from_lineitem(item)
          gi.unlocked_achievements = find_unlocked_achievements_from_lineitem(item)
        end
        gi
      end
      return games
    end

    # These methods are used to find data about a specific game within
    # an HTML "div.lineitem" block from the Xbox Live web site.

    def find_game_id_from_lineitem(lineitem)
      comparison_block = lineitem.at('div.grid-8 div.grid-8 a')
      comparison_url = comparison_block ? comparison_block.get_attribute('href') : nil
      comparison_url ? comparison_url.match(/titleId=(\d+)/)[1] : nil
    end

    def find_game_name_from_lineitem(lineitem)
      name_block = lineitem.at('h3 a')
      name_block ? name_block.inner_html.strip : nil
    end

    def find_game_tile_from_lineitem(lineitem)
      tile_block = lineitem.at('img.BoxShot')
      tile_block ? tile_block.get_attribute('src') : nil
    end

    def find_unlocked_points_from_lineitem(lineitem)
      score_block = lineitem.at('div.grid-4 div.GamerScore')
      score_block ? score_block.inner_html.to_i : nil
    end

    def find_total_points_from_lineitem(lineitem)
      score_block = lineitem.at('div.grid-4 div.GamerScore')
      score_block ? score_block.inner_html.match(/\/ (\d+)/)[1].to_i : nil
    end

    def find_unlocked_achievements_from_lineitem(lineitem)
      score_block = lineitem.at('div.grid-4 div.Achievement')
      score_block ? score_block.inner_html.to_i : nil
    end

    def find_total_achievements_from_lineitem(lineitem)
      score_block = lineitem.at('div.grid-4 div.Achievement')
      score_block ? score_block.inner_html.match(/\/ (\d+)/)[1].to_i : nil
    end

  end

end
