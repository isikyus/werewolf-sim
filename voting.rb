# A voting strategy is a callable object that returns
# either +true+ (lynch this player) or false (do not lynch).
#
# It takes two arguments: the player, and whether the player's
# werewolf/villager status is known.

module Voting
  class Yes 
    def call(_, _)
      true
    end
  end

  class Random
    def call(_, _)
      rand < 0.5
    end
  end

  ALL = [
    Yes,
    Random
  ].map(&:new).freeze
end
