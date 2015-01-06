namespace :scrapper do
  desc 'Scrap data from okGoals'
  task :okgoals => :environment do
    require 'scrappers/okgoals'

    raw_matches = OkGoalsParser.getMatches

    raw_matches.each do |raw_match|
      match = Match.create!(
        home_team: Team.where(name: raw_match[:home][:name]).first_or_create!,
        away_team: Team.where(name: raw_match[:away][:name]).first_or_create!,
        highlight_video: raw_match[:highlightVideo].to_s,
        result: raw_match[:result],
        kickoff: DateTime.parse(raw_match[:date] + ' ' + raw_match[:time])
      )
      raw_match[:goals].each do |goal|
        Goal.create!(
          match: match,
          scorer: goal[:scorer],
          result: goal[:score],
          minute: goal[:minute]
        )
      end
    end
  end
end
