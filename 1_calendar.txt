# List the calendar

> Cal
> Cal 6 2018 # show the calendar of June of 2018

# List all the events
find ~/Library/Calendars -name "*.ics" |
      xargs grep -h -e "SUMMARY" -e "DTSTAMP" |
      sed -E 's/^[A-Z].*:(.*$)/\1/g' |
      sed -E 's/^([0-9]{4})([0-9]{2})([0-9]{2})T([0-9]{2})([0-9]{2})([0-9]{2}).*$/\1-\2-\3 \4:\5:\6/g'

Improvement: can we list only the future events or Today's events?
Someone also suggest to use icalBuddy http://hasseg.org/icalBuddy/. I did not have a chance to try it out yet.

# Add events to the Calendar
osascript -e 'tell application "iCal" to make new event at end of calendar 1 with properties {start date:date "Sunday, September 16, 2018 3:02:00 PM", summary:"test event"}'

Improvement: can we specify which calendar and make it more user friendly?

