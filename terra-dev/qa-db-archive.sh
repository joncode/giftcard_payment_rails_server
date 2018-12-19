#!/bin/bash

backup_path="/Users/ashkin/Dev/ItsOnMe/dbs/dbappdev"

if [ "$1" != "now" ]; then
    echo "This archives a database backup from \`./latest.dump\` to \`$backup_path\`."
    echo
    echo "Run again with \"now\" to move the file."
    echo
    exit
fi


backup_name="dbappdev_`date +%Y-%m-%d_%H-%M-%S`.dump"

/bin/mv "./latest.dump" "$backup_path/$backup_name"

# And output the new path
echo "Archived here: $backup_path/$backup_name"
