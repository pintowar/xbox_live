# XboxLive

XboxLive enables retrieval of player, game, and achievement data from
the Xbox Live web site.

## Status

This is an early pre-release version! The API is almost certain to
change before the 1.0 release.

Questions and suggestions are welcomed, as are pull requests.

## Rails Installation

Include the gem in your Gemfile:

    gem "xbox_live"

## Non-Rails Installation

    gem install xbox_live

## Usage

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

## To Do for Version 1.0

* Complete achievement parsing code
* Write tests
* Finish documentation
* Refactor
* Write page caching code to reduce identical page loads
* Improve API
