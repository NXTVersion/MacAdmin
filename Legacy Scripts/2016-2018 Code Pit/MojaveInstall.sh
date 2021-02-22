 #!/bin/bash

##### VARIABLES #####
## Primary Variables ##
userName=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
macOSVersion=$(sw_vers -productVersion | awk -F. '{print $2}')
workingDir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
targetBootScriptPath="/usr/local"
scriptName="MojaveInstall.sh"

## Function Variables ##
isUserLoggedIn=""
isAPFS=""

## Logging Variables ##
targetVersionName="macOS Mojave"
targetVersion="10.14.5"
timestamp=$(date +"%Y-%m-%d-%H-%M")
logPath="/Library/logs/Install ${targetVersionName} (${targetVersion})-${timestamp}.log"

##### CONDITIONS #####

# Verify if install is running; if yes, quit script
echo "Checking if already running..." >> "${logPath}" 2>&1
if ps aux | grep -v grep | grep "Install ${targetVersionName}"; then
	echo "Install ${targetVersionName} is already running or being downloaded. Skipping install." >> "${logPath}" 2>&1
	exit 1
fi

# Verify MacOS is remotely upgradeable (Supports startosinstall binary)
if ((macOSVersion < 12 )); then
	echo "Current MacOS Version is ${macOSVersion}; and cannot be remotely upgraded to Mojave" >> "${logPath}" 2>&1
	exit 1
fi

##### MAIN BODY #####
main() {
	echo "Begin MacOS Mojave Installation Script..." >> "${logPath}" 2>&1

	#Verify if user is logged in & needs to be notified
	echo "Checking for logged in users..." >> "${logPath}" 2>&1
	CurrentUser
	if [ $isUserLoggedIn == "Yes" ]; then
		echo "Current user is logged in: $userName" >> "${logPath}" 2>&1
		echo "Notifying user of installation..." >> "${logPath}" 2>&1
		utilityNotify
	else
		echo "No user is logged in. Continue with installation script..." >> "${logPath}" 2>&1
	fi

	#If drive is APFS; Wipe and Install. Else UpgradeInstall then Wipe
	echo "Verifying if drive is APFS or not..." >> "${logPath}" 2>&1
	IsAPFS
	if [ $isAPFS == "Yes" ]; then
		echo "Drive is formatted as APFS, erase and install MacOS Mojave..." >> "${logPath}" 2>&1
		EraseAndInstall >> "${logPath}" 2>&1
	else
		echo "Drive does not support --eraseinstall command, setup Upgrade and Install, then wipe and install..." >> "${logPath}" 2>&1
		CopyScript
		CreateDaemon
		UpgradeAndInstall >> "${logPath}" 2>&1
	fi
}

#####################
##### FUNCTIONS #####

# Function: Is user logged in?
function CurrentUser {
	if [ "${userName}" != "" ]; then
		isUserLoggedIn="Yes"
		echo $isUserLoggedIn
	else
		isUserLoggedIn="No"
		echo $isUserLoggedIn
	fi
}

# Function: Is drive APFS?
function IsAPFS {
	if diskutil info / 2>/dev/null | grep 'File System Personality' | grep 'APFS'; then
		isAPFS="Yes"
		echo $isAPFS
	else
		isAPFS="No"
		echo $isAPFS
	fi
}

# Function: Erase and Install
function EraseAndInstall {
	#Verify MacOS Installer is in path
	if [ -d /Applications/Install\ MacOS\ Mojave.app ]; then
		/Applications/Install\ MacOS\ Mojave.app/Contents/Resources/startosinstall --eraseinstall --newvolumename "Macintosh HD" --agreetolicense --nointeraction >> "${logPath}" 2>&1 &
	else
		echo "MacOS Installer is not located in /Applications/" >> "${logPath}" 2>&1
	fi
}

# Function: Upgrade Install
function UpgradeAndInstall {
	if [ -d /Applications/Install\ MacOS\ Mojave.app ]; then
		/Applications/Install\ MacOS\ Mojave.app/Contents/Resources/startosinstall --agreetolicense --nointeraction >> "${logPath}" 2>&1 &
	else
		echo "MacOS Installer is not located in /Applications/" >> "${logPath}" 2>&1
	fi
}

# Function: Notify User
function utilityNotify {
	JH="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
	button1="Button 1"
	button2="Button 2"
	title="Title"
	heading="Heading"
	description="Description"
	timeout=10
	notifyIcon="/usr/local/companyit/company_s_rgb_512x512.png"

	if timeout > 0; then
		"$JH" -icon "$notifyIcon" -windowType utility -title "$title" -heading "$heading" -description "$description" -button2 "$button2" -button1 "$button1" -defaultButton 1 -timeout $timeout
	else
		"${JH}" -icon "$notifyIcon" -windowType utility -title "$title" -heading "$heading" -description "$description" -button2 "$button2" -button1 "$button1" -defaultButton 1
	fi
}

# Function: Copy script to location
function CopyScript {
	cp "${BASH_SOURCE[0]}" $targetBootScriptPath
	/usr/sbin/chown root:admin $targetBootScriptPath/$ScriptName
	/bin/chmod 755 $targetBootScriptPath/$scriptName
	/bin/chmod +x $targetBootScriptPath/$scriptName
}

# Function: Create LaunchDaemon - Boot Script
function CreateDaemon {
echo "Create LaunchDaemon"
cat << EOF > /Library/LaunchDaemons/com.MojaveInstall.plist
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>com.MojaveInstall</string>
		<key>ProgramArguments</key>
		<array>
			<string>/bin/bash</string>
			<string>-c</string>
			<string>/usr/local/MojaveInstall.sh</string>
		</array>
		<key>RunAtLoad</key>
		<true/>
	</dict>
	</plist>
EOF

/usr/sbin/chown root:wheel /Library/LaunchDaemon/com.MojaveInstall.plist
/bin/chmod 644 /Library/LaunchDaemon/com.MojaveInstall.plist
}

#Run main function
main "$@"  #!/bin/bash


##########
## TESTING ##
#
# Test 1:
# Computer - High Sierra, iMac, User logged in
# Deployment - ARD
# User detection Successful
# High Sierra Detection Successful
# APFS detection Successful
# MacOS Upgrade Install Successful
# - BENEIGN ERROR:
#	/bin/bash: line 120: timeout: command not found
#	0No
#	cp: fts_open: No such file or directory
#	chmod: /usr/local/MojaveInstall.sh: No such file or directory
#	chmod: /usr/local/MojaveInstall.sh: No such file or directory
#	Create LaunchDaemon
#	chown: /Library/LaunchDaemon/com.MojaveInstall.plist: No such file or directory
#	chmod: /Library/LaunchDaemon/com.MojaveInstall.plist: No such file or directory
# Pending MacOS Upgrade
