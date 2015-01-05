require './VideoParser.rb'

class GoalsTvParser
  GOALS_TV_URL = "http://goalstv.net/"
  FILE_CACHE = "goalstv.yml"
  def self.getMatches
    response    = HTTParty.get(GOALS_TV_URL)
    parsed_html = Nokogiri::HTML(response.body)

    matches = parsed_html.search('.leftcontainer a b')
    matches_data = []
    matches.each do |match|
      matches_data << parse_match_url(GOALS_TV_URL + match.parent['href'])
    end
    File.open(FILE_CACHE, 'w') {|f| f.write(YAML.dump(matches_data)) }
    return matches_data
  end

  def self.parse_match_url(match_url)
    match_response    = HTTParty.get(match_url)
    parsed_match_html = Nokogiri::HTML(match_response)
    match_info = parsed_match_html.search('.leftcontainer h6').text.gsub(/\t/, '').gsub(/\n/, '')
    match_info = match_info.gsub(/There are no videos yet!/, '')
    date_and_time = match_info[1..(match_info.index(') -'))]
    date = date_and_time[0..(date_and_time.index(' (')-1)]
    time = date_and_time[(date_and_time.index('(')+1)..(date_and_time.length - 5)]

    match_info = match_info[(date_and_time.length + 4)..(match_info.length - 1)]

    stadium = match_info.split('  ')[1]
    match_info = match_info.split('  ')[0]
    competition = match_info[(match_info.index('(')+1)..(match_info.index(')')-1)]
    match_info = match_info[0..(match_info.length - 1 - (competition.length + 2) - 1)]
    home_name_and_result = match_info.split(' - ')[0]
    away_name_and_result = match_info.split(' - ')[1]
    home_name = home_name_and_result[0..(home_name_and_result.rindex(' ') - 1)]
    home_result = home_name_and_result[(home_name_and_result.rindex(' ') + 1)..(home_name_and_result.length)]
    away_result = away_name_and_result[0..(away_name_and_result.index(' ') - 1)]
    away_name = away_name_and_result[(away_name_and_result.index(' ') + 1)..(away_name_and_result.length - 1)]

    highlight_video = VideoParser.parse_sapo_videos(parsed_match_html.search('.leftcontainer iframe'))
    p highlight_video
    return {
      url: match_url,

      date: date,
      time: time,
      home: {
        name: home_name
      },
      away: {
        name: away_name
      },
      stadium: stadium,
      result: "#{home_result}-#{away_result}",
      highlight_video: highlight_video
    }
  end
end
