# pacrimcrew
Script to grab YTD values for Pacrimcrew Strava Club

# Run this script
1. Add required environment variables to your session:  
  -  GOOGLE_SHEETS_CLIENT_ID=
  -  GOOGLE_SHEETS_CLIENT_SECRET=
  -  GOOGLE_SPREADSHEET_ID=
  -  STRAVA_ACCESS_TOKEN=
  -  STRAVA_CLUB_ID=
2. Load console and script: `>> irb -r ./lib/pacrimcrew`
3. Execute script with main entrypoint `>> Pacrimcrew.new.run!`
