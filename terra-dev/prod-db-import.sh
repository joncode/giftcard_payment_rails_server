#!/bin/bash

if [ "$1" != "now" ]; then
    echo "This imports a captured backup from \`./latest.dump\` into the \`drinkboard_dev\` database."
    echo
    echo "Run again with \"now\" to start the import."
    echo
    exit
fi

# Begin the import
pg_restore --verbose --clean --no-acl --no-owner -h localhost -d drinkboard_dev ./latest.dump
