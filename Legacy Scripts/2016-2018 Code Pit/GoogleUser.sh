#!/bin/sh
##########
## Script: 8x8Reset.sh
## CreatedBy: Damian Finger
## CreationDate: 05/31/19
## LastModified: 05/31/19
## Purpose:
## Read the Current User logged into Google Chrome
## ##########

## VARIABLES ##
currentUser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
homeDir=$(dscl . read /Users/$currentUser NFSHomeDirectory | awk -F': ' '{print $NF}')

#Copy Chrome local state to temporary location
sudo scp $homeDir/Library/Application\ Support/Google/Chrome/Local\ State /tmp/

#Convert Chrome Local State to plist
sudo mv /tmp/Local\ State /tmp/Local\ State.plist
sudo plutil -convert xml1 /tmp/Local\ State.plist

#Return logged in username for Chrome browser
sudo defaults read /tmp/Local\ State.plist | grep "user_name" | awk -F'"' '{print $4}'

result=`sudo defaults read /tmp/Local\ State.plist | grep "user_name" | awk -F'"' '{print $4}'`

echo "<result>$result</result>"