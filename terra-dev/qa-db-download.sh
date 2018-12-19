#!/bin/bash

if [ "$1" != "now" ]; then
    echo "This downloads a backup of the \`dbappdev\` database and stores it in the current folder."
    echo
    echo "Run again with \"now\" to start."
    echo
    exit
fi

# Begin download
heroku pg:backups:download  --app dbappdev
