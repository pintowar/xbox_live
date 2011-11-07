# XboxLive

XboxLive enables retrieval of player, game, and achievement data from
the Xbox Live web site.

## Status

This is an early pre-release version! The API is almost certain to
change before the 1.0 release.

Questions and suggestions are welcomed, as are pull requests.

## Installation

Include the gem in your Gemfile:

    gem "xbox_live"

Or, if you aren't using Bundler, just run:

    gem install xbox_live

## Configuration

An Xbox Live username and password must be provided so that the gem
can log into the Xbox Live web site to retrieve data.

To configure these settings, include the following lines (substituting
your information) in your program, or for Rails applications, create
a `config/initializers/xbox_live.rb` file and add the lines there:

    # Your Xbox Live login and password
    XboxLive.options[:username] = 'your@email.address'
    XboxLive.options[:password] = 'password'

Two optional configuration options are also available, but are not
required to be set:

    # Pages retrieved from Xbox Live are cached for 10 minutes (600
    # seconds) by default, to prevent unnecessary reloads from the Xbox
    # Live web site. The maximum cache age can be changed here.
    XboxLive.options[:refresh_age] = 300  # Cache for only 5 minutes

    # Show debugging output on the console.
    XboxLive.options[:debug] = true

## Example

Below is a short sample stand-alone program to demonstrate basic
functionality. This sample program is also included in the git
repository.

    require 'xbox_live'

    # Your Xbox Live login and password
    XboxLive.options[:username] = 'your@email.address'
    XboxLive.options[:password] = 'password'

    player = 'gamertag'

    profile_page = XboxLive::ProfilePage.new(player)
    puts "Gamerscore: #{profile_page.gamerscore}"

    games_page = XboxLive::GamesPage.new(player)
    first_game = games_page.games.first
    puts "Score in '#{first_game.name}': #{first_game.unlocked_points} out of #{first_game.total_points}"

    achievements_page = XboxLive::AchievementsPage.new(player, first_game.id)
    first_ach = achievements_page.achievements.first
    puts "Unlocked achievement '#{first_ach.name}' on #{first_ach.unlocked_on}"

This will output something along these lines (depending on the gamertag
entered for the `player` variable:

    Gamerscore: 9454.
    Score in 'Battlefield 3': 100 out of 1000.
    Unlocked achievement '1st Loser' on 10/28/2011.

## Caveats

The contents, layout, and authentication scheme for the Xbox Live web
site may change at any time, and historically has changed several times
per year. These changes will almost certainly break the functionality
of this gem, requiring a new version of the gem to be coded and
released.

## To Do for Version 1.0

* Write tests
* Refactor
* Improve API
