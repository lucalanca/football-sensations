class Team < ActiveRecord::Base
  has_many :home_matches, class_name: 'Match', foreign_key: 'home_team'
  has_many :away_matches, class_name: 'Match', foreign_key: 'away_team'
end
