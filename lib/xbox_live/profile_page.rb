module XboxLive

  # Each ProfilePage tracks and makes available the data contained in an Xbox
  # Live profile web page. This can be used to determine general information
  # about a payer, such as their total score, avatar picture, or bio.
  #
  # Example: http://live.xbox.com/en-US/MyXbox/Profile?Gamertag=someone
  class ProfilePage

    attr_accessor :gamertag, :page, :url, :updated_at, :gamerscore, :motto,
      :avatar, :gamertile_small, :nickname, :bio, :activity


    # Create a new ProfilePage for the provided gamertag. Retrieve the
    # html profile page from the Xbox Live web site for analysis.
    def initialize(gamertag)
      @gamertag = gamertag
      refresh
    end


    # Force a reload of the ProfilePage data from the Xbox Live web site.
    # Ensure a minimal amount of time has gone by before doing a refresh.
    def refresh
      return false if @updated_at and Time.now - @updated_at < XboxLive.options[:refresh_age]
      url = XboxLive.options[:url_prefix] + '/en-US/MyXbox/Profile?' +
        Mechanize::Util.build_query_string(gamertag: @gamertag)
      @page = XboxLive::Scraper::get_page url
      return false if @page.nil?

      @url = url
      @updated_at = Time.now
      @gamerscore = find_gamerscore
      @motto    = find_motto
      @avatar   = find_avatar
      @nickname = find_nickname
      @bio      = find_bio
      @activity = find_activity
      @gamertile_small = find_gamertile_small

      return true
    end

    private

    # Find and return the player's gamerscore from the ProfilePage
    def find_gamerscore
      score_block = @page.at('div.Gamerscore')
      score_block ? score_block.inner_html.to_i : nil
    end

    # Find and return the player's motto from the ProfilePage
    def find_motto
      motto_block = @page.at('div#Motto')
      motto_block ? motto_block.inner_html.strip : nil
    end

    # Find and return the player's avatar url from the ProfilePage
    def find_avatar
      avatar_block = @page.at('img.AvatarBody')
      avatar_block ? avatar_block.get_attribute('src') : nil
    end

    # Find and return the player's small gamertile url from the ProfilePage
    def find_gamertile_small
      tile_block = @page.at('img.GamerTile')
      tile_block ? tile_block.get_attribute('src') : nil
    end

    # Find and return the player's nickname from the ProfilePage
    def find_nickname
      nickname_block = @page.at('div#ProfileInfo h2')
      nickname_block ? nickname_block.inner_html.strip : nil
    end

    # Find and return the player's bio from the ProfilePage
    def find_bio
      bio_block = @page.at('div#bio')
      bio_block ? bio_block.inner_html.strip : nil
    end

    # Find and return the player's most recent activity from the ProfilePage
    def find_activity
      activity_block = @page.at('div#CurrentActivity')
      activity_block ? activity_block.inner_html.strip : nil
    end
  end

end
