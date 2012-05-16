require 'xbox_live'

# Your Xbox Live login and password
XboxLive.options[:username] = 'your@email.address'
XboxLive.options[:password] = 'password'
XboxLive.options[:debug] = false

player = 'gamertag'

profile_page = XboxLive::ProfilePage.new(player)
puts "Gamerscore: #{profile_page.gamerscore}"

games_page = XboxLive::GamesPage.new(player)
first_game = games_page.games.first
puts "Score in '#{first_game.name}': #{first_game.unlocked_points} out of #{first_game.total_points}"

achievements_page = XboxLive::AchievementsPage.new(player, first_game.id)
first_ach = achievements_page.achievements.first
puts "Unlocked achievement '#{first_ach.name}' at '#{first_ach.unlocked_at}'" 

