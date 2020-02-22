require "./game"
require "./voting"
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

vote_trials = Voting::ALL.product(Voting::ALL)
vote_trials.each do |villager_voting, werewolf_voting|
  @iterations ||= 10_000
  @iterations.times do |t|
    @players = []
    3.times do
      @players << Werewolf.new(voting: werewolf_voting)
    end

    villager_count = 12
    @players << Seer.new(strategy: AnyWerewolf, voting: villager_voting)

    @players << Hunter.new(voting: villager_voting)
    @players << Cupid.new(voting: villager_voting)

    (villager_count - 3).times do
      @players << Villager.new(voting: villager_voting)
    end

    outcome[Game.new(@players).run(@verbose)] += 1
  end

  puts "#{villager_voting.class.name} villagers vs #{werewolf_voting.class.name} werewolves: #{outcome.inspect}"
end
