#!/bin/bash

 if [ "$1" != "now" ]; then
     echo "This captures, downloads, imports, and archives a backup of the \`drinkboard\` database."
     echo
     echo "Run again with \"now\" to begin."
     echo
     exit
 fi


 echo "Beginning capture, download, import, and archive of the Production Database."
./prod-db-capture.sh now && ./prod-db-download.sh now && ./prod-db-import.sh now && ./prod-db-archive.sh now

