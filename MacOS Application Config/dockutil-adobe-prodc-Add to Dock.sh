#!/bin/bash
## --- HEADER --- ##
# Created By: Damian Finger
# Created On: 03/29/21
# Updated By: Damian Finger
# Updated On: 03/29/21
# Audited By: Damian Finger
# Audited On: 03/29/21
# Purpose Other Notes: Script used to Add Adobe Pro DC Application to dock if installed
## --- ------ --- ##

## Standard Variables ##
currentUser=$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}     ')
dockutilPath="/usr/local/bin/dockutil"
jamfPath="/usr/local/bin/jamf"

## Active Variables ##
dockApps=(
	"Adobe Acrobat DC/Adobe Acrobat.app"
	)

## JAMF Triggers ##
dockutilTrigger="dockUtil"

## Logging Variables ##

function verifyDockutil {
	# Verify if dockutil is installed
	if [ -f ${dockutilPath} ]; then
		echo "dockutil is installed correctly."
	else
		# If dockutil is not installed, run JAMF Trigger
		echo "dockutil is not installed; Running JAMF Trigger..."
		"${jamfPath}" policy -trigger "${dockutilTrigger}"
		# If dockutil is still not installed; exit 1
		if [ ! -f ${dockutilPath} ]; then
			exit 1
		fi
	fi
}
function addAppArray {
	for APP in "${dockApps[@]}"; do
		if [ -d /Applications/"$APP" ]; then
			su "$currentUser" -c "${dockutilPath} --add /Applications/'$APP' --position beginning"
		else
			echo "Application '$APP' is not installed"
		fi
	done
}
main() {
	verifyDockutil
    addAppArray
}


main "$@"
