#!/bin/bash
##########
## Script: Automation - Enforce 2FA.sh
## CreatedBy: Damian Finger
## CreationDate: 01/26/21
## ModifiedDate: 04/26/21
## Purpose: Purpose of this script is to automate Google Workspace 2FA Enforcement with little End User interruption.
##### END OF HEADER #####
#########################

## Editable Variables ##
workingOU="orgUnitPath='/PEPofAZ/Users/TEST - Enforce 2FA'"
exceptionGroup="exception.2fa@pepofaz.com"
notificationCap="5"

## Script Variables ##
allusers=($(gam print users query "$workingOU")); allusers=( "${allusers[@]/primaryEmail}")
disabled2FAUsers=() 	# Use function 2FADisabledArray
enabled2FAUsers=()		# Use function 2FAEnabledArray

# Create Array of Users with 2FA Enabled
function 2FAEnabledArray {
	echo "Creating array of users with 2FA Enabled..."

	# Create Array of users who have 2FA Enabled
	for user in ${allusers[@]}; do
		if [[  `gam info user zz_testing@pepofaz.com | grep "2-step enrolled:" | sed 's/.*2-step enrolled: //'``` == "True" ]]; then
			enabled2FAUsers+=($user)
		fi
	done
	echo ""
}

# Create Array of Users with 2FA Disabled
function 2FADisabledArray {
	echo "Creating array of users with 2FA Disabled..."

	# Create Array of users who have 2FA Disabled
	for user in ${allusers[@]}; do
		if [[  `gam info user zz_testing@pepofaz.com | grep "2-step enrolled:" | sed 's/.*2-step enrolled: //'``` == "False" ]]; then
			disabled2FAUsers+=($user)
		fi
	done
	echo ""
}

# Add Disabled 2FA Users to Exceptions Google Group
function addUsersExceptionGroup {
	echo "Adding users with 2FA Disabled to Exception Group..."

	# If users have 2FA Disabled; verify Notification Counter
	for users in ${disabled2FAUsers[@]}; do
		if [[ "$(verifyNotificationCounter $users)" < $notificationCap ]]
		if [[ `gam print groups member $users | grep $exceptionGroup` ]]; then
			echo "$users is already in group $exceptionGroup."
		else
			gam update group $exceptionGroup add member user $users
		fi
	done
	echo ""
}

# Remove Enabled 2FA Users from Exceptions Google Group
function removeUsersExceptionGroup {
	echo "Removing users with 2FA Enabled from Exception Group..."

	# If users are in Exceptions Google Group; remove them
	for users in ${enabled2FAUsers[@]}; do
		if [[ `gam print groups member $users | grep $exceptionGroup` ]]; then
			gam update group $exceptionGroup remove user $users
		else
			echo "$users is not in group $exceptionGroup."
		fi
	done
	echo ""
}

# Return Custom Schema Notifiation Counter
function verifyNotificationCounter {
	echo `gam info user $1 | grep "2FA_Notifications_Sent:" | sed 's/.*2FA_Notifications_Sent: //'```
}

## Main Body ##
#2FAEnabledArray
#removeUsersExceptionGroup
#2FADisabledArray
#addUsersExceptionGroup
if [[ "$(verifyNotificationCounter zz_testing@pepofaz.com)" < 1 ]]; then
	echo "True"
else
	echo "False"
fi

## Notion Documentation ##
# https://www.notion.so/nxtversion/Engineering-Enforce-GSuite-2FA-f6a9fa04388341d1b095f07a5df2c2f5
