#!/bin/bash

function VARIABLES {
	jamfChromeTrigger="AppGoogleChrome"
	dockApps=(
		"Google Chrome.app"
		"Chat.app"
	)
}

main() {
	currentUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
	
	VARIABLES
	RemoveAllDock
	DisableRecents
	ADDDOCKAPPS
}

function RemoveAllDock {
	if [ -f /usr/local/bin/dockutil ]; then
		echo "Dockutil is installed; removing applications from dock..."
		sudo su $currentUser -c '/usr/local/bin/dockutil --remove all'
		sudo su $currentUser -c '/usr/local/bin/dockutil --add '~/Downloads' --view grid --display folder'
	else
		echo "Dockutil not installed..."
		exit 0
	fi
}

function DisableRecents {
	sudo su $currentUser -c 'defaults write /Users/'$currentUser'/Library/Preferences/com.apple.dock show-recents -bool false'
	sudo su $currentUser -c 'killall Dock'
}

function ADDDOCKAPPS {
	for APP in ${dockApps[@]}; do
		if [ -d /Applications/"$APP" ]; then
			sudo su $currentUser -c '/usr/local/bin/dockutil --add /Applications/"$APP" --position beginning'
		else
			if [ -f /usr/local/bin/jamf ]; then
				/usr/local/bin/jamf policy --trigger "$jamfChromeTrigger"
				sleep 10
				sudo su $currentUser -c '/usr/local/bin/dockutil --add /Applications/'$APP' --position beginning'
			else
				echo "JAMF not installed"
			fi
		fi
}

function AddChrome {
	if [ -d /Applications/Google\ Chrome.app ]; then
		sudo su $currentUser -c '/usr/local/bin/dockutil --add /Applications/Google\ Chrome.app --position beginning'
	else
		if [ -f /usr/local/bin/jamf ]; then
			/usr/local/bin/jamf policy --trigger "$jamfChromeTrigger"
			sleep 10
			sudo su $currentUser -c '/usr/local/bin/dockutil --add /Applications/Google\ Chrome.app --position beginning'
		else
			echo "JAMF not installed"
		fi
	fi
}

main "$@"