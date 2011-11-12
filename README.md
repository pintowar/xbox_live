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

## Available Data

The `XboxLive::ProfilePage` class makes the following data available
from a player's Profile page, via a call like `profile_page =
XboxLive::ProfilePage.new(gamertag)`:

* `profile_page.gamertag`
* `profile_page.gamerscore`
* `profile_page.motto`
* `profile_page.avatar`
* `profile_page.gamertile_small`
* `profile_page.nickname`
* `profile_page.bio`
* `profile_page.presence`

The `XboxLive::GamesPage` class makes the following data available from
a player's Game Comparison page, via a call like `games_page =
XboxLive::GamesPage.new(gamertag)`:

* `games_page.gamertag`
* `games_page.gamertile_large`
* `games_page.gamerscore`
* `games_page.progress`
* `games_page.games` _(see below)_

`games_page.games` is an Array of XboxLive::GameInfo instances, which track information about a
player's progress in a game. Each GameInfo instance makes the following data available:

* `game_info.id` - unique Microsoft identifier
* `game_info.name`
* `game_info.tile`
* `game_info.total_points`
* `game_info.total_achievements`
* `game_info.gamertag`
* `game_info.unlocked_points`
* `game_info.unlocked_achievements`
* `game_info.last_played`

The `XboxLive::AchievementsPage` class makes the following data
available from a player's Game Achievement Comparison page, via a call
like `ach_page = XboxLive::AchievementsPage.new(gamertag, game_id)`:

* `ach_page.gamertag`
* `ach_page.game_id`
* `ach_page.achievements` _(see below)_

`ach_page.achievements` is an Array of XboxLive::AchievementInfo
instances, which track information about a player's achievements in a
game. Each AchievementInfo instance makes the following data available:

* `ach_info.id` - Microsoft identifier, unique only within this game
* `ach_info.gamertag`
* `ach_info.game_id`
* `ach_info.name`
* `ach_info.description`
* `ach_info.tile`
* `ach_info.points`
* `ach_info.unlocked_at` - nil if the player has not yet unlocked it

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
