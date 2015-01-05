require 'httparty'
require 'nokogiri'
require './VideoParser.rb'

class OkGoalsParser
  OK_GOALS_URL = "http://www.okgoals.com/"
  FILE_CACHE = "okgoals-matches.yml"

  def self.getMatches
    response    = HTTParty.get(OK_GOALS_URL)
    parsed_html = Nokogiri::HTML(response.body)

    matches = parsed_html.search('.listajogos a')
    matches_data = []
    matches.each do |match|
      match_url = match['href']
      p match_url
      matches_data << parse_match_url(match_url)
    end
    File.open(FILE_CACHE, 'w') {|f| f.write(YAML.dump(matches_data)) }
    return matches_data
  end

  def self.parse_match_url(match_url)
    match_response    = HTTParty.get(OK_GOALS_URL + match_url)
    parsed_match_html = Nokogiri::HTML(match_response)


    match_info = parsed_match_html.search('.titulojogos').first.text.to_s.strip.gsub(/\t/, ' ')
    date = match_info[0, match_info.index('(') - 1]
    time = match_info[(match_info.index('(')+1)..(match_info.index(')')-1)]
    home_team = match_info[(match_info.index('-')+2)..(match_info.rindex('-')-3)]
    away_team = match_info[(match_info.rindex('-')+3)..(match_info.length - 1)]

    result = match_info[(match_info.index(home_team) + home_team.length + 1)..(match_info.index(away_team) - 2)]


    videos_info = parsed_match_html.search('.contentjogos')
    hasHighlights = videos_info.text.include?('Highlights')
    goals = videos_info.text.gsub('Highlights', '').gsub(/\n/, '€').gsub(/€€/, '€').split('€')
    parsed_goals = []
    goals.each do |goal|
      if !goal.empty?
        p "goal: #{goal}"
        goal_score  = goal[0..(goal.index(' ') - 1)]
        goal = goal[(goal.index(' '))..(goal.length - 1)]
        goal_scorer = goal[(goal.index(' ')+1)..(goal.rindex(' ')-1)]
        goal_minute  = goal[(goal.rindex(' ')+1)..(goal.length - 1)]

        parsed_goal = {
          score: goal_score,
          scorer: goal_scorer,
          minute: goal_minute
        }
        p parsed_goal
        parsed_goals << parsed_goal
      end
    end

    # p parsed_goals
    highlightVideo = nil
    videos_info.search('script').each_with_index do |video, index|
      parsed_video = VideoParser.parse_playwire_video(video)
      if hasHighlights
        if index == 0
          highlightVideo = parsed_video
        else
          parsed_goals[index-1][:video] = parsed_video
        end
      else
        if parsed_goals.length == 0
          highlightVideo = parsed_video
        else
          parsed_goals[index][:video] = parsed_video
        end
      end
    end

    if parsed_goals.length == 1 && parsed_goals[0][:scorer] == "Goals"
      highlightVideo = parsed_goals[0][:video]
      parsed_goals = []
    end


    return {
      url: match_url,
      date: date,
      time: time,
      home: {
        name: home_team
      },
      away: {
        name: away_team
      },
      result: result,
      goals: parsed_goals,
      highlightVideo: highlightVideo
    }
  end
end
