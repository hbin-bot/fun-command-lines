#!/bin/bash

# Set up some pathway and method below
wd=`pwd`
. ~/.nvm/nvm.sh

rail_dir=${wd}/rail_app/
ember_dir=${wd}/ember_app/

osascript <<-EndOfScript
    tell application "iTerm"
        -- split the windows of iTerm
        tell current session of current window
            set columns to 400
            set rows to 200
            split vertically with default profile
            split horizontally with default profile
        end tell

        -- run the code in each iTerm window
        tell first session of current tab of current window
            write text "cd ${rail_dir}"
            write text "echo \"Starting Redis and Local Database ... \""
            write text "brew services stop redis"
            write text "brew services start redis"
            write text "pg_ctl -D /usr/local/var/postgresql@9.6/ stop"
            write text "pg_ctl -D /usr/local/var/postgresql@9.6/ start &"
            write text "echo \"Ready to start Rails App ... \""
            write text "rails s"
        end tell

        tell second session of current tab of current window
            write text "cd ${ember_dir}"
            write text "nvm use 10.16.0"
            write text "echo \"Ready to start ember ......\""
            write text "npx ember s --environment=development"
        end tell

        tell third session of current tab of current window
            write text "cd ${wd}"
            write text "echo \"This is the active session now:\""
            select
        end tell
    end tell
EndOfScript