require 'pry'
class Villager
  def initialize
    @alive = true
    @condemned = false
    @identified = false
  end

  def alive?
    @alive
  end

  def role_prevents_lynching?
    false
  end

  def werewolf?
    false
  end

  def villager?
    !werewolf?
  end

  def seer?
    false
  end

  def identify!
    @identified = true
  end

  def identified?
    @identified
  end

  def condemned?
    @condemned
  end

  def condemn!
    @condemned = true
  end

  def die!
    @alive = false
  end

  def vote(victim)
    true
  end
end

class Seer < Villager
  def initialize(strategy:)

    @strategy = strategy
    super()
    identify!
  end

  def role_prevents_lynching?
    true
  end

  def identify_randomly(players)
    players.reject(&:condemned?).reject(&:identified?).sample&.identify!
  end

  def seer?
    true
  end

  def should_reveal?(players)
    @strategy.should_reveal?(self, players)
  end
end

class AnyWerewolf
  def self.should_reveal?(seer, players)
    werewolf_count = players.select(&:werewolf?).count
    villager_count = players.reject(&:werewolf?).count
    identified_werewolf_count = players.select(&:werewolf?).select(&:identified?).count
    identified_villager_count = players.reject(&:werewolf?).select(&:identified?).count

    return true if werewolf_count == identified_werewolf_count
    return true if villager_count == identified_villager_count
    return true if identified_villager_count + identified_werewolf_count >= (players.count / 2)
    return true if identified_werewolf_count >= 2
    return true if identified_villager_count > 6
    # seer.identified_werewolfs(players).count >= (players.select(&:werewolf?).count / 4) ||
  end
end


class Hunter < Villager
  def role_prevents_lynching?
    true
  end
end

class Cupid < Villager
  def role_prevents_lynching?
    true
  end
end

class Werewolf < Villager
  def werewolf?
    true
  end
end

class Game
  def initialize(players)
    @players = players
  end

  def run(verbose=false)
    while !game_over? do
      eaten_villager = eat_a_villager
      identify_someone if seer
      log_state("after night") if verbose

      if eaten_villager.is_a?(Hunter)
        lynch_someone(hunter_killing: true)
        log_state("hunter killed") if verbose
      end

      seer_reveals! if seer && seer.should_reveal?(alive_players)
      lynch_someone(verbose: verbose)

      log_state("lynched") if verbose
    end

    @outcome
  end

  def log_state(message)
    statuses = @players.map do |player|
      letter = if player.alive?
        letter = player.class.name.chars.first
      else
        '-'
      end

      state_symbol = if player.condemned?
                       '!'
                     elsif player.identified?
                       '*'
                     else
                       ' '
                     end

      letter + state_symbol
    end

    puts "#{statuses.join(' ')} #{message}"
  end

  def seer
    villagers.detect(&:seer?)
  end

  def alive_players
    @players.select(&:alive?)
  end

  def seer_reveals!
    @players.select(&:identified?).map(&:condemn!)
  end

  def eat_a_villager
    eaten_villager = condemned_villagers.first || villagers.sample

    eaten_villager.die!
    eaten_villager
  end

  def villagers
    @players.select(&:alive?).reject(&:werewolf?)
  end

  def werewolfs
    @players.select(&:alive?).select(&:werewolf?)
  end

  def identify_someone
    seer.identify_randomly(@players.select(&:alive?))
  end

  def condemned_wolves
    werewolfs.select(&:condemned?)
  end

  def condemned_villagers
    villagers.select(&:condemned?)
  end

  def lynching_nominee(safe: [])
    (condemned_wolves - safe).first || (alive_players - safe).reject(&:condemned?).sample
  end

  def lynch_someone(hunter_killing: false, safe: [], verbose: false)
    lynched_person = lynching_nominee(safe: safe)

    if !hunter_killing
      return if lynched_person.nil?

      if lynched_person.role_prevents_lynching?
        lynched_person.condemn!
        if lynched_person.seer?
          seer_reveals!
        end

        safe << lynched_person
        return lynch_someone(safe: safe, verbose: verbose)
      end

      unless vote_to_lynch(lynched_person, verbose: verbose)
        safe << lynched_person
        return lynch_someone(safe: safe, verbose: verbose)
      end

      return if lynched_person.nil?
    end

    lynched_person.die!
    lynched_person
  end

  def vote_to_lynch(lynched_person, verbose: false)
    votes = @players.map { |p| p.vote(lynched_person) }

    puts "#{votes.map { |v| v ? 'y' : 'n' }.join('  ')} vote to lynch #{@players.index(lynched_person)}" if verbose

    votes.select { |vote| vote }.count > (votes.length / 2)
  end

  def game_over?
    if werewolfs.count >= villagers.count
      @outcome = :werewolf_win
    elsif werewolfs.count == 0
      @outcome = :villagers_win
    else
      false
    end
  end
end
