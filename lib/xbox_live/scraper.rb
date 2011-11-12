module XboxLive

  # Scraper is a collection of methods to log into the Xbox Live web site
  # and retrieve web pages.
  # 
  # The only public function is XboxLive::Scraper.get_page(url)
  module Scraper

    # Since loading pages from the Xbox Live web site is expensive
    # (slow), pages should be cached for a short amount of time in case
    # they are re-requested again.
    @cache = Hash.new

    # Load a page from Xbox Live and return a Mechanize/Nokogiri page
    # TODO: cache pages for some time to prevent duplicative HTTP activity
    def self.get_page(url)
      log "Loading page #{url}."

      # Check to see if there is a recent version of the page in cache
      if @cache[url]
        log "  Found page in cache."
        return @cache[url][:page] if Time.now - @cache[url][:updated_at] < XboxLive.options[:refresh_age]
        log "    but the cached page is stale."
      end

      # Load the specified page via Mechanize
      log "  Getting page from Xbox Live."
      page = agent.get(url)

      # Most pages require authentication. If the Mechanize agent has
      # not logged in yet, or if the session has expired, it will be
      # redirected to the Xbox Live login page.
      if login_page?(page)
        # Log the agent in via the returned login page.
        log "  Page load failed - not signed in."
        page = login(page)

        # The login SHOULD have returned the original page requested,
        # but the URL will be the POST URL, so there is no way to be
        # certain. Therefore, it is safest to just load the page again
        # now that the Mechanize agent has logged in.
        log "  Retrying page #{url}"
        page = agent.get(url)
      end

      if page.nil?
        log "  ERROR: failed to load page."
        return nil
      end

      if page.uri.to_s != url
        log "  ERROR: loaded page URL does not match expected URL. Loaded: #{page.uri.to_s}"
        return nil
      end

      log "  Loaded page '#{page.title.strip}'. Storing in cache."
      @cache[url] = { page: page, updated_at: Time.now }
      page
    end

    # POST a page to Xbox Live and return the result.
    def self.post_page(url, params)
      log "POSTing page #{url} with params #{params}."
      page = agent.post(url, params)
      page
    end


    private

    # Log in to Xbox Live using the supplied login page.
    def self.login(page)
      return nil if !login_page?(page)

      # Find the URL where the login form should be POSTed to.
      url = page.body.match(/srf_uPost='([^']+)/)[1]
      if url.empty?
        log "  ERROR: Trying to log in but 'Sign In' page doesn't contain needed info."
        return nil
      end

      # PPFT appears to be some kind of session identifier which is
      # required for the login process.
      ppft_html = page.body.match(/srf_sFT='([^']+)/)[1]
      ppft = ppft_html.match(/value="([^"]+)/)[1]

      # The rest of the parameters are either user-provided (i.e.
      # username and password) or are constants.
      params = {
        'login' => XboxLive.options[:username],
        'passwd' => XboxLive.options[:password],
        'type' => '11',
        'LoginOptions' => '3',
        'NewUser' => '1',
        'PPSX' => 'Passpor',
        'PPFT' => ppft,
        'idshbo' => '1'
      }

      # POST the login form and hope for the best.
      log "  Submitting login form via POST"
      page = agent.post(url, params)

      # The login will fail and return a page saying that Javascript must be
      # enabled. However, there is a hidden form in the page that can be
      # submitted to enable non-javascript support.
      form = page.form('fmHF')
      if form.nil?
        log "  ERROR: The non-JS login page doesn't contain form fmHF."
        return nil
      end

      # Submitting the form on the Javascript error page completes the
      # login process, and SHOULD return the originally requested page.
      log "  Submitting final non-JS login form"
      agent.submit(form)
    end

    # Check to see if the provided page the Xbox Live login page.
    def self.login_page?(page)
      page and page.title == "Welcome to Windows Live"
    end

    # Create and memoize the Mechanize agent
    def self.agent
      log "  Initializing mechanize agent @ #{Time.now.to_s}" if !defined? @@agent
      @@agent ||= Mechanize.new { |a| a.user_agent_alias = 'Mac Safari' }
    end

    # Write out a log entry
    def self.log(message)
      puts message if XboxLive.options[:debug]
    end

  end

end
