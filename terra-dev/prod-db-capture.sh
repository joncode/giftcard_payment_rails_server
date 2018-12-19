#!/bin/bash

if [ "$1" != "now" ]; then
    echo "This initiates a backup of the \`drinkboard\` database."
    echo
    echo "Run again with \"now\" to start the backup."
    echo
    exit
fi

# Begin a backup
heroku pg:backups:capture  --app drinkboard DATABASE_URL

