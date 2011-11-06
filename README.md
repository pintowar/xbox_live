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

One additional configuration option is available, if desired:

    XboxLive.options[:debug] = true

## Example

Below is a short sample stand-alone program to demonstrate basic
functionality. This sample program is also included in the git
repository.

    require 'xbox_live'

    # Your Xbox Live login and password
    XboxLive.options[:username] = 'your@email.address'
    XboxLive.options[:password] = 'password'
    XboxLive.options[:debug] = false

    player = 'gamertag'

    profile_page = XboxLive::ProfilePage.find(player)
    puts "Gamerscore: #{profile_page.gamerscore}."

    games_page = XboxLive::GamesPage.find(player)
    first_game = games_page.games.first
    puts "Score in '#{first_game[:game_name]}': #{first_game[:player_points]} out of #{first_game[:game_points]}."

    achievements_page = XboxLive::AchievementsPage.find(player, first_game[:game_id])
    first_ach = achievements_page.achievements.first
    puts "Unlocked achievement '#{first_ach[:name]}' on #{first_ach[:unlocked_on]}."

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

* Complete achievement parsing code
* Write tests
* Finish documentation
* Refactor
* Write page caching code to reduce identical page loads
* Improve API
