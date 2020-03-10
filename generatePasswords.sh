#!/bin/bash

# Passwords generator.
# Generated passwords will appear as new lines in file in the home (default) or manually selected directory.
# User should define the length and quantity of passwords.

echo "---"
echo -n "Enter desired length of passwords (8 to 16): "
read "length"
lengthCheck=$(expr "$length" : "[0-9]*$") # Check for non-empty string and non-digit characters.
echo "---"

echo -n "Enter desired quantity of passwords (1 to 100): "
read "quantity"
quantityCheck=$(expr "$quantity" : "[0-9]*$") # Check for non-empty string and non-digit characters.
echo "---"

if [[ (( $lengthCheck -gt 0 )) && (( $quantityCheck -gt 0 )) && \
(( "$length" -ge 8 )) && (( "$length" -le 16 )) && \
(( "$quantity" -ge 1 )) && (( "$quantity" -le 100 )) ]] # Check out-of-range length and quantity.
then
    dirDefault=$(getent passwd $(whoami) | cut -d: -f6) # Set target directory by default.
    echo -n "Enter path (full) where the file with generated passwords will be stored (or leave it blank - your home dir will be set): "
    read dirUser
    if [[ -z "$dirUser" ]] # Select final working directory.
    then
	dirWork="$dirDefault"
    else
	mkdir -p "$dirUser"
	dirWork="$dirUser"
    fi
    echo "---"
    echo "File with generated passwords will be stored at: ${dirWork}"
    available=$(df -P "$dirWork" | awk 'END{print $4}')
    echo "Up to $available KB available here."
    if (($available > 0)) # Check space availability.
    then
	echo -n "" > "$dirWork/GeneratedPasswords.txt"
	echo "Generating..."
	tempPass=0
	i=0
	echo "Start" > "$dirWork/TEST.txt"
	while [ $i -lt $quantity ]
	do
	    tempPass=$(head /dev/urandom | tr -dc [:lower:][:upper:][:digit:] | head -c $length)
	    echo $tempPass >> "$dirWork/TEST.txt"
	    if [[ $tempPass =~ [a-z] && $tempPass =~ [A-Z] && $tempPass =~ [0-9] ]]
	    then
		echo $tempPass >> "$dirWork/GeneratedPasswords.txt"
		i=$(($i+1))
	    fi
	done
	if [ $i -eq $quantity ]
	then
	    echo "Generated successfully!"
	fi
    else
	echo "There is no enough space to create new files."
    fi
else
    echo "Oops, retry! There is an incorrect length or number of passwords entered above."
fi