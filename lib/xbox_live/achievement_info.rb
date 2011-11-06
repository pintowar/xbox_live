module XboxLive

  # Each AchievementInfo tracks information about a player's progress in a
  # specific achievement.
  class AchievementInfo

    attr_accessor :id, :game_id, :gamertag, :name, :description, :tile, :points, :unlocked_on

    # Create a new AchievementInfo for the provided player and game.
    def initialize(gamertag, game_id, achievement_id)
      @gamertag = gamertag
      @game_id = game_id
      @id = achievement_id
    end

  end

end

