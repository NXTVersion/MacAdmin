#!/bin/bash


# This script is designed to automatically initiate the installation of specified mac OS installer.
# No user interaction is included in this script and the preferred distribution is recurring check in.

### VERIFY THAT ALL VARIABLES ARE IN PLACE FOR SPECIFIC INSTALL. VARIABLES WILL NEED TO BE UPDATED WITH NEWER OS VERSIONS

# Written by: Damian Finger
# Script written with elements from MacOSUpgrade script and RebootOnRecon script with custom elements added.
# Created On: January 17th, 2018

## USER VARIABLES

# Specify path to OS installer. Use Parameter 4 in the JSS, or specify here
# Example: /Applications/Install macOS High Sierra.app
OSInstaller="$4"

# Version of OS. Use Parameter 5 in the JSS, or specify here.
# Example: 10.12.5
version="$5"

# Trigger used for download. Use Parameter 6 in the JSS, or specify here.
# This should match a custom trigger for a policy that contains an installer
# Example: download-sierra-install
download_trigger="$6"

# Title of OS
# Example: macOS High Sierra
macOSname=`echo "$OSInstaller" |sed 's/^\/Applications\/Install \(.*\)\.app$/\1/'`

# Logged in User
currentUser=$(stat -f %Su "/dev/console")

# PID for login window
WindowServer="$(ps -axc | grep WindowServer | awk '{print $1}')"

## SYSTEM CHECKS

# Check currently installed OS version
currentOS=$(sw_vers | grep "ProductVersion" | awk '{ print $2 }')
if [[ $currentOS == "10.13.3" ]]; then
	echo "Computer is already up to date." exit 1
else
	echo "$currentOS currently installed. Proceeding with update."
fi

# Check if device is on battery or ac power
pwrAdapter=$( /usr/bin/pmset -g ps )
if [[ ${pwrAdapter} == *"AC Power"* ]]; then
		pwrStatus="OK"
		/bin/echo "Power Check: OK - AC Power Detected"
else
		pwrStatus="ERROR"
		/bin/echo "Power Check: ERROR - No AC Power Detected"
fi

# Check if free space > 15GB
osMinor=$( /usr/bin/sw_vers -productVersion | awk -F. {'print $2'} )
if [[ $osMinor -ge 12 ]]; then
		freeSpace=$( /usr/sbin/diskutil info / | grep "Available Space" | awk '{print $6}' | cut -c 2- )
else
		freeSpace=$( /usr/sbin/diskutil info / | grep "Free Space" | awk '{print $6}' | cut -c 2- )
fi

if [[ ${freeSpace%.*} -ge 15000000000 ]]; then
		spaceStatus="OK"
		/bin/echo "Disk Check: OK - ${freeSpace%.*} Bytes Free Space Detected"
else
		spaceStatus="ERROR"
		/bin/echo "Disk Check: ERROR - ${freeSpace%.*} Bytes Free Space Detected"
fi

# Check for existing OS installer
if [ -e "$OSInstaller" ]; then
	/bin/echo "$OSInstaller found, checking version."
	OSVersion=`/usr/libexec/PlistBuddy -c 'Print :"System Image Info":version' "$OSInstaller/Contents/SharedSupport/InstallInfo.plist"`
	/bin/echo "OSVersion is $OSVersion"
	if [ $OSVersion = $version ]; then
		downloadOS="No"
	else
		downloadOS="Yes"
		# Delete old version.
		/bin/echo "Installer found, but old. Deleting..."
		/bin/rm -rf "$OSInstaller"
	fi
else
	downloadOS="Yes"
fi

# Download OS installer if needed
if [ $downloadOS = "Yes" ]; then
	##Run policy to cache installer
	/usr/local/jamf/bin/jamf policy -event $download_trigger
else
	/bin/echo "$macOSname installer with $version was already present, continuing..."
fi

# Check to see if user is currently logged in
while [[ $currentUser != "root" ]]; do
	echo "User logged in. attempting forced logout"
	kill -HUP $WindowServer
	sleep 5
	currentUser=$(stat -f %Su "/dev/console")
	(( c++ )) && (( c>=3 )) && break
done

# Cancel Apple Setup Asssistant on next boot
jamf createSetupDone -suppressSetupAssistant

## CREATE FIRST BOOT SCRIPT

/bin/mkdir /usr/local/companyit

/bin/echo "#!/bin/bash
## First Run Script to remove the installer.
## Clean up files
/bin/rm -fdr "$OSInstaller"
/bin/sleep 30
## Update Device Inventory
/usr/local/jamf/bin/jamf recon
## Remove LaunchDaemon
/bin/rm -f /Library/LaunchDaemons/com.companyit.cleanupOSInstall.plist
## Remove Script
/bin/rm -fdr /usr/local/companyit/finishOSInstall.sh
exit 0" > /usr/local/companyit/finishOSInstall.sh

/usr/sbin/chown root:admin /usr/local/companyit/finishOSInstall.sh
/bin/chmod 755 /usr/local/companyit/finishOSInstall.sh

## LAUNCH DAEMON

cat << EOF > /Library/LaunchDaemons/com.companyit.cleanupOSInstall.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
		<key>Label</key>
		<string>com.companyit.cleanupOSInstall</string>
		<key>ProgramArguments</key>
		<array>
				<string>/bin/bash</string>
				<string>-c</string>
				<string>/usr/local/companyit/finishOSInstall.sh</string>
		</array>
		<key>RunAtLoad</key>
		<true/>
</dict>
</plist>
EOF

# Set the permission on the file just made.
/usr/sbin/chown root:wheel /Library/LaunchDaemons/com.companyit.cleanupOSInstall.plist
/bin/chmod 644 /Library/LaunchDaemons/com.companyit.cleanupOSInstall.plist

# Installation process
if [[ ${pwrStatus} == "OK" ]] && [[ ${spaceStatus} == "OK" ]] && [[ $currentUser == "root" ]]; then
# Start OS Install
	/bin/echo "Launching startosinstall..."
	"$OSInstaller/Contents/Resources/startosinstall" --applicationpath "$OSInstaller" --nointeraction
else
	# Remove previously created script
	/bin/rm -f /usr/local/companyit/finishOSInstall.sh
	/bin/rm -f /Library/LaunchDaemons/com.companyit.cleanupOSInstall.plist
	/bin/echo "Installation requirements not met."
	exit 1
fi
exit 0
