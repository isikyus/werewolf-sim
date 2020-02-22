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

    def name
      'always-yes'
    end
  end

  class Random
    def call(_, _)
      rand < 0.5
    end

    def name
      'random'
    end
  end

  class ByWolfStatus
    def initialize(play_for_wolves, fallback)
      @play_for_wolves = play_for_wolves
      @fallback = fallback
    end

    def call(nominee, identified)
      if identified
        # Vote to kill anyone not on our side
        nominee.werewolf? != @play_for_wolves
      else
        @fallback.call(nominee, identified)
      end
    end

    def name
      our_name = if @play_for_wolves
        'against_villagers'
      else
        'against_wolves'
      end

      "#{our_name}(#{@fallback.name})"
    end
  end

  ALL = [
    Yes.new,
    Random.new,
    ByWolfStatus.new(false, Yes.new),
    ByWolfStatus.new(false, Random.new),
    ByWolfStatus.new(true, Yes.new),
    ByWolfStatus.new(true, Random.new)
  ].freeze
end
