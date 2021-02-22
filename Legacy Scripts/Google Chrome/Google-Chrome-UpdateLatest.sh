#!/bin/bash

## --- HEADER --- ##
# Created By: Damian Finger
# Created On: 02/29/20
# Updated By: Damian Finger
# Updated On: 02/29/20
# Audited By: Damian Finger
# Audited On: 02/29/20
# Purpose: Script to update Google Chrome to the latest Zero Day Exploit release. Functions for Addigy and JAMF.
## --- ------ --- ##

# Function containing variables used in the script
function VARIABLES {
	
	# Default variables used in script
	DOWNLOAD_URL="https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
	DMG_PATH="/tmp/Google Chrome.dmg"
	DMG_VOLUME_PATH="/Volumes/Google Chrome/"
	APP_NAME="Google Chrome.app"
	APP_PATH="/Applications/$APP_NAME"
	APP_PROCESS_NAME="Google Chrome"
	APP_INFO_PLIST="Contents/Info.plist"
	APP_VERSION_KEY="CFBundleShortVersionString"
	APP_PERMISSION_USER="root"
	APP_PERMISSION_GROUP="wheel"
}

# Main Function running script
main() {
	VARIABLES #Assign Variables
	UPDATECHROME
	
}

function UPDATECHROME {
	if pgrep "$APP_PROCESS_NAME" &>/dev/null; then
		printf "Error - %s is currently running!" "$APP_PROCESS_NAME"
	else
		curl --retry 3 -L "$DOWNLOAD_URL" -o "$DMG_PATH"
		hdiutil attach -nobrowse -quiet "$DMG_PATH"
		version=$(defaults read "$DMG_VOLUME_PATH/$APP_NAME/$APP_INFO_PLIST" "$APP_VERSION_KEY")
		printf "Installing $APP_PROCESS_NAME version %s" "$version"
		ditto -rsrc "$DMG_VOLUME_PATH/$APP_NAME" "$APP_PATH"
		chown -R "$APP_PERMISSION_USER":"$APP_PERMISSION_GROUP" "$APP_PATH"
		hdiutil detach -quiet "$DMG_PATH"
		rm "$DMG_PATH"
	fi

}

main "$@"