#!/bin/bash

# Textfiles generator.
# Generated files will appear in the home (default) or manually selected directory.
# User should define the quantity of files.
# Size of each file is a random-defined value in range 10-20 MB.

echo "---"
echo -n "Enter desired quantity of files (1 to 10): "
read "quantity"
quantityCheck=$(expr "$quantity" : "[0-9]*$") # Check for non-empty string and non-digit characters.
echo "---"

if [[ (( $quantityCheck -gt 0 ))  && (( "$quantity" -ge 1 )) && (( "$quantity" -le 10 )) ]] # Check out-of-range quantity.
then

    dirDefault=$(getent passwd $(whoami) | cut -d: -f6) # Set target directory by default.
    echo -n "Enter path (full) where generated files will be stored (or leave it blank - your home dir will be set): "
    read "dirUser"
    if [[ -z "$dirUser" ]] # Select final working directory.
    then
	dirWork="$dirDefault"
    else
	mkdir -p "$dirUser"
	dirWork="$dirUser"
    fi
    echo "---"
    echo "Generated files will be stored at: ${dirWork}"

    available=$(df -P "$dirWork" | awk 'END{print $4}')
    totalSize=$((quantity * 20000))
    echo "Up to $available KB available here."
    echo "Up to $totalSize KB required for $quantity files."
    echo "---"
    if (($available > $totalSize)) # Check space availability.
    then
	echo -n "Would you like to write files with zero bytes or random characters? (z/r): "
	read fill
	echo "---"
	if [[ (( $fill = "z" )) || (( $fill = "r" )) ]] # Check for correct answer.
	then
	    i=0
	    while [ $i -lt $quantity ]
	    do
		countBlock=0
		while [ "$countBlock" -le 10 ]
		do
		    countBlock=$RANDOM
		    let "countBlock %= 20"
		done
		echo "Size of file-${fill}-${i} is $countBlock MB."
		echo "Generating..."
		
		case $fill in
		    z)
			dd if=/dev/zero of="$dirWork/file-${fill}-${i}" bs=1M count=$countBlock
			;;
		    r)
			dd if=/dev/urandom of="$dirWork/file-${fill}-${i}" bs=1M count=$countBlock
			;;
		esac
		
		i=$(($i+1))
	    done
	    echo "---"
	    if [ $i -eq $quantity ]
	    then
		echo "Generated successfully!"
	    fi
	else
	    echo "Oops! Incorrect filling type."
	fi
    else
	echo "There is no enough space to create new files."
    fi
else
    echo "Oops, retry! There is an incorrect number of files entered above."
fi