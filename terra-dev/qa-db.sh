#!/bin/bash

 if [ "$1" != "now" ]; then
     echo "This captures, downloads, imports, and archives a backup of the \`dbappdev\` database."
     echo
     echo "Run again with \"now\" to begin."
     echo
     exit
 fi


 echo "Beginning capture, download, import, and archive of the QA Database."
./qa-db-capture.sh now && ./qa-db-download.sh now && ./qa-db-import.sh now && ./qa-db-archive.sh now

