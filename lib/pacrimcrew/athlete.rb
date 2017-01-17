class Pacrimcrew::Athlete
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def raw
    @raw ||= Pacrimcrew.client.retrieve_another_athlete(id)
  end

  def link
    "#{base_url}/#{id}"
  end

  def last_name
    raw['lastname']
  end

  def first_name
    raw['firstname']
  end

  def name
    "#{first_name} #{last_name}"
  end

  def username
    raw['username']
  end

  def base_url
    'https://www.strava.com/athletes'
  end

  def url
    "#{base_url}/#{id}"
  end

  def options
    # Trick strava into thinking this is a browser request
    {
      headers: {
        "User-Agent" => "Mozilla/5.0"
      }
    }
  end

  def stats
    response = HTTParty.get(url, options)
    page = Nokogiri::HTML.parse(response.body)
    {
      ytd: ytd(page),
      all_time: all_time(page)
    }
  end

  def no_running_stats_present?(page)
    cycling_stats_present?(page)
  end

  def cycling_stats_present?(page)
    # Since we're scraping the HTML, the athlete needs to set his/her
    # default sport to Running. Otherwise it may display stats for a
    # different activity
    !!page.search(".athlete-records").search('thead').text[/Cycling/]
  end

  def ytd(page)
    return {} if no_running_stats_present?(page)
    ytd = page.search(".athlete-records").search('.spans8').first
    keys = ytd.search('tbody th').map(&:text)
    values = ytd.search('tbody td').map(&:text)
    results = keys.zip(values).to_h

    # Fetch total time in minutes
    match = /(?<hours>\d+)h\s(?<minutes>\d+)m/.match(results.fetch('Time'))
    hours = match[:hours].to_i
    minutes = match[:minutes].to_i

    {
      distance:  results.fetch('Distance').to_f, # 100mi
      time:      hours * 60 + minutes, # 15h 33m
      elev_gain: results.fetch('Elevation Gain').to_i, # 3,000ft
      runs: results.fetch('Runs').to_i # 50
    }
  end

  def all_time(page)
    return {} if no_running_stats_present?(page)
    all_time = page.search(".athlete-records").search('.spans8').last
    keys = all_time.search('tbody th').map(&:text)
    values = all_time.search('tbody td').map(&:text).map{|str| str.gsub(',', '')}
    results = keys.zip(values).to_h

    # Fetch total time in minutes
    match = /(?<hours>\d+)h\s(?<minutes>\d+)m/.match(results.fetch('Total Time'))
    hours = match[:hours].to_i
    minutes = match[:minutes].to_i

    {
      total_distance: results.fetch('Total Distance').to_f,
      total_time: hours * 60 + minutes,
      total_elev_gain: results.fetch('Total Elev Gain').to_i,
      total_runs: results.fetch('Total Runs').to_i
    }
  end
end

