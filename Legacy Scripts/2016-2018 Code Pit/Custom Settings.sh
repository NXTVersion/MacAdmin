#!/bin/sh

main() {
########################################
########################################
## EDITABLE VARIABLES ##
	# System Settings
	# Set each setting to ON, OFF, or DEFAULT

	CUPSINTERFACE=ON
	LOCKSCREENSHUTDOWN=ON
	FASTUSERSWITCH=ON
	EMPTYTRASH30=OFF
	LOGINWINDOWTEXT=OFF
	OSAUTOUPDATE=OFF
	GUESTACCOUNT=OFF

#### DO NOT EDIT PAST THIS LINE ####
########################################
########################################
########################################

CUPS $CUPSINTERFACE
LOCKSCREEN $LOCKSCREENSHUTDOWN
FASTUSER $FASTUSERSWITCH
EMPTYTRASH $EMPTYTRASH30
LOGINTEXT $LOGINWINDOWTEXT
OSAUTOUPDATE $OSAUTOUPDATE
GUESTACCOUNT $GUESTACCOUNT
}

## Function to enable/disable CUPS Web Interface ##
function CUPS {
	if [ "$1" == "ON" ]; then
		cupsctl WebInterface=yes
	elif [ "$1" == "OFF" ]; then
		cupsctl WebInterface=no
	elif [ "$1" == "DEFAULT" ]; then
		cupsctl WebInterface=no
	else
		echo ERROR: CUPSINTERFACE variable unknown. Please set as ON, OFF, or DEFAULT
		exit 1
	fi
}


## Function to enable/disable the "Shutdown" and "Restart" buttons display on lock screen ##
function LOCKSCREEN {
	if [ "$1" == "ON" ]; then
		defaults write /Library/Preferences/com.apple.loginwindow.plist PowerOffDisabled -int 0
	elif [ "$1" == "OFF" ]; then
		defaults write /Library/Preferences/com.apple.loginwindow.plist PowerOffDisabled -int 1
	elif [ "$1" == "DEFAULT" ]; then
		defaults write /Library/Preferences/com.apple.loginwindow.plist PowerOffDisabled -int 1
	else
		echo ERROR: LOCKSCREENSHUTDOWN variable unknown. Please set as ON, OFF, or DEFAULT
		exit 1
	fi
}

function FASTUSER {
	if [ "$1" == "ON" ]; then
		sudo defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool 'YES'
	elif [ "$1" == "OFF" ]; then
		sudo defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool 'NO'
	elif [ "$1" == "DEFAULT" ]; then
		sudo defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool 'NO'
	else
		echo ERROR: LOCKSCREENSHUTDOWN variable unknown. Please set as ON, OFF, or DEFAULT
		exit 1
	fi
}

function EMPTYTRASH {
	if [ "$1" == "ON" ]; then
		defaults write com.apple.finder FXRemoveOldTrashItems -bool true
	elif [ "$1" == "OFF" ]; then
		defaults write com.apple.finder FXRemoveOldTrashItems -bool false
	elif [ "$1" == "DEFAULT" ]; then
		defaults write com.apple.finder FXRemoveOldTrashItems -bool false
	else
		echo ERROR: LOCKSCREENSHUTDOWN variable unknown. Please set as ON, OFF, or DEFAULT
		exit 1
	fi
}

function LOGINTEXT {
		if [ "$1" == "ON" ]; then
				defaults write /Library/Preferences/com.apple.loginwindow.plist SHOWFULLNAME -bool true
		elif [ "$1" == "OFF" ]; then
				defaults write /Library/Preferences/com.apple.loginwindow.plist SHOWFULLNAME -bool false
		elif [ "$1" == "DEFAULT" ]; then
				defaults write /Library/Preferences/com.apple.loginwindow.plist SHOWFULLNAME -bool false
		else
				echo ERROR: LOCKSCREENSHUTDOWN variable unknown. Please set as ON, OFF, or DEFAULT
				exit 1
		fi
}

function OSAUTOUPDATE {
		if [ "$1" == "ON" ]; then
				defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool TRUE
		elif [ "$1" == "OFF" ]; then
				defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool FALSE
		elif [ "$1" == "DEFAULT" ]; then
				defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool TRUE
		else
				echo ERROR: LOCKSCREENSHUTDOWN variable unknown. Please set as ON, OFF, or DEFAULT
				exit 1
		fi
}

function GUESTACCOUNT {
		if [ "$1" == "ON" ]; then
				defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool true
		elif [ "$1" == "OFF" ]; then
				defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
		elif [ "$1" == "DEFAULT" ]; then
				defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
		else
				echo ERROR: LOCKSCREENSHUTDOWN variable unknown. Please set as ON, OFF, or DEFAULT
				exit 1
		fi
}

main "$@"