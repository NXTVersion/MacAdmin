#!/bin/bash

# Script to do the following:
# 1. Create directory for custom scripts
# 2. Create script to run in Launchd
# 3. Create Launchd

main () {
	CreateScriptDir
	CreateScript
	CreateLaunchd
}

# Function to verify FT Scripts directory exists
function CreateScriptDir {
	if [ ! -d /Library/FT/Scripts ]; then
		echo "FT Scripts directory does not exists"
		echo "Creating FT Scripts directory..."
		sudo mkdir -p /Library/FT/Scripts
	else
		echo "FT Scripts directory exists"
	fi
}

# Function to create script
function CreateScript {
	destPath="/Library/FT/Scripts"
	scriptName="Interval-NXT-OneDriveOffload.sh"
	
	cd $destPath
	sudo touch $scriptName

# Create script here under EOF
sudo tee << EOF $destPath/$scriptName > /dev/null
!#/bin/bash
# Testing Script
mkdir /tmp/TestingSuccess
EOF

	sudo chmod u+x $destPath/$scriptName
}

# Create LaunchD
function CreateLaunchd {
	# Launchd Path Variables
	currentUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
	userDir="/Users/$currentUser"
	userAgentPath="$userDir/Library/LaunchAgents"
	globalAgentPath="/Library/LaunchAgents"
	globalDaemonPath="/Library/LaunchDaemons"
	systemAgentPath="/System/Library/LaunchAgents"
	systemDaemonPath="/System/Library/LaunchDaemons"
	launchdName="com.ft.nxtOnedriveOffload.plist"
	interval=7200
	
sudo tee << EOF $userAgentPath/$launchdName > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$launchdName</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/bash</string>
		<string>-c</string>
		<string>$destPath/$scriptName</string>
	</array>
	<key>StartInterval</key>
	<integer>$interval</integer>
</dict>
</plist>
EOF

	sudo launchctl load $userAgentPath/$launchdName

}

main "$@"