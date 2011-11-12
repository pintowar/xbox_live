module XboxLive

  # Each ProfilePage tracks and makes available the data contained in an Xbox
  # Live profile web page. This can be used to determine general information
  # about a payer, such as their total score, avatar picture, or bio.
  #
  # Example: http://live.xbox.com/en-US/Profile?Gamertag=someone
  class ProfilePage

    attr_accessor :gamertag, :page, :url, :updated_at, :gamerscore, :motto,
      :avatar, :gamertile_small, :nickname, :bio, :presence


    # Create a new ProfilePage for the provided gamertag. Retrieve the
    # html profile page from the Xbox Live web site for analysis.
    def initialize(gamertag)
      @gamertag = gamertag
      refresh
    end


    # Force a reload of the ProfilePage data from the Xbox Live web site.
    #
    # TODO: Parse the Location: and reputation fields as well.
    def refresh
      url = XboxLive.options[:url_prefix] + '/en-US/Profile?' +
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
      @presence = find_presence
      @gamertile_small = find_gamertile_small

      return true
    end

    private

    # Find and return the player's gamerscore from the ProfilePage
    def find_gamerscore
      score_block = @page.at('div.gamerscore')
      score_block ? score_block.inner_html.to_i : nil
    end

    # Find and return the player's motto from the ProfilePage
    def find_motto
      motto_block = @page.at('div.motto')
      # TODO: Need to strip out the empty bubble-arrow div
      motto_block ? motto_block.inner_html.strip : nil
    end

    # Find and return the player's avatar url from the ProfilePage
    def find_avatar
      # FIXME: Not currently working. Javascript?
      avatar_block = @page.at('img.bodyshot')
      avatar_block ? avatar_block.get_attribute('src') : nil
    end

    # Find and return the player's small gamertile url from the ProfilePage
    def find_gamertile_small
      tile_block = @page.at('img.gamerpic')
      tile_block ? tile_block.get_attribute('src') : nil
    end

    # Find and return the player's nickname from the ProfilePage
    def find_nickname
      nickname_block = @page.at('div.name div.value')
      nickname_block ? nickname_block.inner_html.strip : nil
    end

    # Find and return the player's bio from the ProfilePage
    def find_bio
      bio_block = @page.at('div.bio div.value')
      bio_block ? bio_block.inner_html.strip : nil
    end

    # Find and return the player's most recent presence info from the ProfilePage
    def find_presence
      presence_block = @page.at('div.presence')
      presence_block ? presence_block.inner_html.strip : nil
    end
  end

end
