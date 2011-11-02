module XboxLive

  # Scraper is a collection of methods to log into the Xbox Live web site
  # and retrieve web pages.
  # 
  # The only public function is XboxLive::Scraper.get_page(url)
  module Scraper

    # Load a page from Xbox Live and return a Mechanize/Nokogiri page
    # TODO: cache pages for some time to prevent duplicative HTTP activity
    def self.get_page(url)
      log "Getting page #{url}"

      page = agent.get(url)
      if login_page?(page)
        log "Page load failed - not signed in."
        page = login(page)
        page = agent.get(url)
      end

      if page.nil? or page.uri.to_s != url
        log "FATAL: loaded page URL does not match expected URL. Loaded: #{page.uri.to_s}"
        return nil
      end

      log "Loaded page #{page.title}"
      return page
    end

    private

    # Log in to Xbox Live using the supplied login page
    def self.login(page)
      return nil if !login_page?(page)

      # No science, just voodoo. Figured all this out through trial and
      # error.
      url = page.body.match(/srf_uPost='([^']+)/)[1]
      ppft_html = page.body.match(/srf_sFT='([^']+)/)[1]
      ppft = ppft_html.match(/value="([^"]+)/)[1]
      if url.empty?
        log "FATAL: Trying to log in but Sign In page doesn't contain needed info."
        return nil
      end

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
      page = agent.post(url, params)

      # The login will fail and return a page saying that Javascript must be
      # enabled, but there's a hidden form in the page that can be submitted to
      # enable non-javascript support.
      form = page.form('fmHF')
      if form.nil?
        log "FATAL: Trying to log in but non-JS page doesn't contain form fmHF."
        return nil
      end

      page = agent.submit(form)
      return page
    end

    # Is the given page the Xbox Live login page?
    def self.login_page?(page)
      page and page.title == "Welcome to Windows Live"
    end

    # Create and memoize the Mechanize agent
    def self.agent
      log "Initializing mechanize agent @ #{Time.now.to_s}" if !defined? @@agent
      @@agent ||= Mechanize.new { |a| a.user_agent_alias = 'Mac Safari' }
    end

    # Write out a log entry
    def self.log(message)
      puts message if XboxLive.options[:debug]
    end

  end

end
