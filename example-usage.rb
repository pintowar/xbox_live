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

