#!/bin/bash

main () {
	SetPaths
	RemoveiWork
	RemoveDockItems
}

function SetPaths {
	# List paths of iWork suite as variables
	garageBand="/Applications/GarageBand.app"
}

function RemoveiWork {
	# Delete iWorks suite if exists
	sudo rm -rf "$garageBand"
}

function RemoveDockItems {
	currentUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
	
	if [ -f /usr/local/bin/dockutil ]; then
		sudo dockutil --remove 'GarageBand' "/Users/$currentUser"
	fi
	
}

main "$@"