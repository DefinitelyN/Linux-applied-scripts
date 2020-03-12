#!/bin/bash

# The purpose of this script is to periodically get some system info and store it in a log file.
# When main log file size grows up to 1 MB, all data moves to "old" file (overwriting it).

dirWork="/var/log" # Set target directory.
fileName="mySysStatLog.txt"
fileNameOld="mySysStatLog.old.txt"

available=$(df -P "$dirWork" | awk 'END{print $4}')

if [ $available -gt 0 ] # Check space availability.
then

    if [ ! -f "$dirWork/$fileName" ] # Creating log and "old" log files if they are not already exist.
    then
	touch "$dirWork/$fileName"
	touch "$dirWork/$fileNameOld"
    fi

    while true
    do
	if [ `stat -c "%s" "$dirWork/$fileName"` -lt 1024*1024 ] # Check main file size.
	then
	    echo "---Start of log---" >> "$dirWork/$fileName"
	    echo "Current date and time: "$(date +%d.%m.%Y\ %H:%M:%S) >> "$dirWork/$fileName"
	    echo "Logged-in users: "$(who) >> "$dirWork/$fileName"
	    echo "System uptime: "$(uptime) >> "$dirWork/$fileName"
	    echo "---End of log---" >> "$dirWork/$fileName"
	    echo "" >> "$dirWork/$fileName"
	elif [ `stat -c "%s" "$dirWork/$fileName"` -ge 1024*1024 ]
	then
	    cp -f "$dirWork/$fileName" "$dirWork/$fileNameOld"
	    echo -n "" > "$dirWork/$fileName"
	fi
	sleep 10 # Wait for 10 seconds.
    done

fi