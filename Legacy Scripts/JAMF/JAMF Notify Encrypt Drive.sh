#!/bin/bash

function VARIABLES {
	JHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
	title="Disk Encryption Required"
	heading="Log Out Required"
	description="Your computer required Disk Encryption, please log out of your computer and back in. You will be prompted to enter your password on logout."
	iconPath=""
	button1="Log Out Now"
	#button2="Delay Restart"
	defaultButton=`open -a Safari.app`
	#cancelButton=""
	#delayOptions="0, 60, 120, 600, 1800, 3600"
}

main() {
	VARIABLES
	BUILDNOTIFY
}

function BUILDNOTIFY {
	"${JHelper}" -windowType hud -title "${Title}" -heading "${heading}" -description "${description}" -button1 "${button1}"
}

main "$@"