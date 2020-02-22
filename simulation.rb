require "./game"
require "optparse"

OptionParser.new do |opts|
  opts.on('-i', '--iterations ITERATIONS', 'Number of iterations to run') do |iterations|
    @iterations = iterations.to_i
  end

  opts.on('-v', '--verbose', 'Output more details of each run') do
    @verbose = true
  end
end.parse!


outcome = {
  werewolf_win: 0,
  villagers_win: 0
}

@iterations ||= 10_000
@iterations.times do |t|
  @players = []
  3.times do
    @players << Werewolf.new
  end

  villager_count = 12
  @players << Seer.new(strategy: AnyWerewolf)

  @players << Hunter.new
  @players << Cupid.new

  (villager_count - 3).times do
    @players << Villager.new
  end

  outcome[Game.new(@players).run(@verbose)] += 1
end

puts outcome.inspect

