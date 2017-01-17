require "google_drive"

class Pacrimcrew::GoogleSheets
  GOOGLE_SHEETS_CLIENT_ID = ENV['GOOGLE_SHEETS_CLIENT_ID']
  GOOGLE_SHEETS_CLIENT_SECRET = ENV['GOOGLE_SHEETS_CLIENT_SECRET']
  SPREADSHEET_ID = ENV['SPREADSHEET_ID']

  attr_reader :stats

  def initialize(stats)
    @stats = stats
  end

  def create!
    # First worksheet
    sheet = session.spreadsheet_by_key(SPREADSHEET_ID).worksheets[0]

    row = 3
    stats.each do |athlete|
      sheet[row,1] = athlete[:name]
      sheet[row,2] = athlete[:username]
      sheet[row,3] = athlete[:link]
      sheet[row,4] = athlete[:stats][:ytd][:distance]
      sheet[row,5] = athlete[:stats][:ytd][:time]
      sheet[row,6] = athlete[:stats][:ytd][:elev_gain]
      sheet[row,7] = athlete[:stats][:ytd][:runs]
      sheet[row,8] = athlete[:stats][:all_time][:total_distance]
      sheet[row,9] = athlete[:stats][:all_time][:total_time]
      sheet[row,10] = athlete[:stats][:all_time][:total_elev_gain]
      sheet[row,11] = athlete[:stats][:all_time][:total_runs]
      row += 1
    end

    sheet.save
  end

  def session
    GoogleDrive::Session.from_config(File.join(Pacrimcrew.root_path, 'config.json'))
  end
end

