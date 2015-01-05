require 'httparty'
require 'nokogiri'

require './VideoParser.rb'

class LiveFootballParser
  LIVE_FOOTBALL_VIDEO_URL = "http://livefootballvideo.com/highlights/"
  FILE_CACHE = "livefootball-matches.yml"

  def self.getMatches
    # return if !File.file?(FILE_CACHE)
      response    = HTTParty.get(LIVE_FOOTBALL_VIDEO_URL)
      parsed_html = Nokogiri::HTML(response.body)

      matches = parsed_html.xpath('//*[@id="content"]/div/ul/li')
      matches_data = []
      matches.each do |match|
        league      = match.search('.leaguelogo a').first.attr('title')
        match_url   = match.search('.result a').first['href']
        p match_url
        matches_data << parse_match_url(match_url, { league: league })
      end
      File.open(FILE_CACHE, 'w') {|f| f.write(YAML.dump(matches_data)) }
      return matches_data
    # else
    #   return YAML.load(File.read(FILE_CACHE)
    # end
  end

  def self.parse_match_url (match_url, match_data)
    match_response    = HTTParty.get(match_url)
    parsed_match_html = Nokogiri::HTML(match_response)

    teams_els   = parsed_match_html.search('.match_info tr').first
    team_home   = teams_els.search('.left').first.text
    team_away   = teams_els.search('.right').first.text

    highlight_video_script = parsed_match_html.search('#highlights script')
    highlight_video        = VideoParser.parse_playwire_video(highlight_video_script) if highlight_video_script

    result = parsed_match_html.search('.scoretime').text.strip

    details = parsed_match_html.search('.details tr')
    week = details[0].text
    date = details.search('.fulldate').text
    time = details.search('.time').text

    home_form = (parsed_match_html.search('.left .form span').map { |f| f.text }).join("")
    away_form = (parsed_match_html.search('.right .form span').map { |f| f.text }).join("")
    home_logo = parsed_match_html.search('.left .logo img').first['src']

    return match_data.merge({
      url: match_url,

      date: date,
      time: time,
      week: week,
      home: {
        name: team_home,
        form: home_form
      },
      away: {
        name: team_away,
        form: away_form
      },
      result: result,
      highlight_video: highlight_video
    })
  end

  private_class_method :parse_match_url
end
