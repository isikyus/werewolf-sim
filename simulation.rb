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

@iterations ||= 10_000

results = Voting::ALL.map do |villager_voting|
  Voting::ALL.map do |werewolf_voting|

    outcome = {
      werewolf_win: 0,
      villagers_win: 0
    }

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

    outcome
  end
end

# Show a table of results, and a key
headers = ['villager_voting', 'worst score', *0...Voting::ALL.length]
rows = [ headers ]
results.each_with_index do |result_row, index|
  villager_scores = result_row.map { |outcome| outcome[:villagers_win] }
  rows << [index, villager_scores.min, *villager_scores]
end

puts rows.map { |r| r.join(' ') }

puts
puts "Voting Systems by ID:"
Voting::ALL.each_with_index do |system, index|
  puts "#{index}: #{system.name}"
end
