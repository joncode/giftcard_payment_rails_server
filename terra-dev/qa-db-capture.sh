#!/bin/bash

if [ "$1" != "now" ]; then
    echo "This captures a backup of the \`dbappdev\` database. and stores it in the current folder."
    echo
    echo "Run again with \"now\" to start the capture."
    echo
    exit
fi

# Begin a backup
heroku pg:backups:capture  --app dbappdev DATABASE_URL

