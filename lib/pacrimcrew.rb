$:.unshift File.expand_path('../pacrimcrew', __FILE__)
require 'nokogiri'
require 'json'
require 'strava/api/v3'

class Pacrimcrew
  STRAVA_ACCESS_TOKEN = ENV['STRAVA_ACCESS_TOKEN']
  STRAVA_CLUB_ID = ENV['STRAVA_CLUB_ID']
  WAYNE=369236

  def self.root_path
    Pathname.new(File.dirname(File.dirname(__FILE__)))
  end

  def self.client
    @@client ||= Strava::Api::V3::Client.new(access_token: STRAVA_ACCESS_TOKEN)
  end

  def client
    Pacrimcrew.client
  end

  def members
    @members ||= client.list_club_members(STRAVA_CLUB_ID)
  end

  def member_ids
    # Array of athlete IDs
    members.map { |member| member.fetch('id') }
  end

  def stats
    @stats ||= member_ids.reject{|id| id == WAYNE}.map do |athlete_id|
      athlete = Pacrimcrew::Athlete.new(athlete_id)
      {
        name: athlete.name,
        id: athlete.id,
        link: athlete.link,
        username: athlete.username,
        stats: athlete.stats
      }
    end
  end

  def run!
    Pacrimcrew::GoogleSheets.new(stats).create!
  end
end

require 'athlete'
require 'google_sheets'
