#!/bin/bash
##########
## Script: Automation - Enforce 2FA.sh
## CreatedBy: Damian Finger
## CreationDate: 01/26/21
## ModifiedDate: 01/26/21
## Purpose: Purpose of this script is to automate Google Workspace 2FA Enforcement with little End User interruption.
## Documentation: https://www.notion.so/nxtversion/Engineering-Enforce-GSuite-2FA-f6a9fa04388341d1b095f07a5df2c2f5
##### END OF HEADER #####
#########################

## Editable Variables ##
workingOU="orgUnitPath='/Domain/Users/TEST - Enforce 2FA'"
exceptionGroup="exception.2fa@email.com"
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

# Return Custom Schema Notifiation Counter
function verifyNotificationCounter {
	echo `gam info user $1 | grep "2FA_Notifications" | sed 's/.*2FA_Notifications: //'`
}

# Add Disabled 2FA Users to Exceptions Google Group (Verify Notification Counter)
function addUsersExceptionGroup {
	echo "Adding users with 2FA Disabled to Exception Group..."

	echo "Updating 2FADisabledArray..."
	2FADisabledArray

	# If users have 2FA Disabled; verify Notification Counter
	for users in ${disabled2FAUsers[@]}; do
		# If disabled 2FA User has not been notified & is not in Exception Group; add to exception group.
		if [[ "$(verifyNotificationCounter $users)" < $notificationCap
		&& ! `gam print groups member $users | grep $exceptionGroup` ]]; then
			echo "$users notifictation counter is less than $notificationCap & is not a member of $exceptionGroup."
			gam update group $exceptionGroup add member user $users
		# Else disabled 2FA User has not been notified & is already in Exception Group; do nothing
		else
			echo "$users notification counter is less than $notificationCap & is already a member of $exceptionGroup."
		fi
	done
	echo ""
}

# Remove Enabled 2FA Users from Exceptions Google Group
function removeUsersExceptionGroup {
	echo "Removing users with 2FA Enabled from Exception Group..."

	echo "Updating 2FAEnabledArray..."
	2FAEnabledArray

	# If users have 2FA Enabled; Remove them from Exception Group.
	for users in ${enabled2FAUsers[@]}; do
		if [[ `gam print groups member $users | grep $exceptionGroup` ]]; then
			gam update group $exceptionGroup remove user $users
		else
			echo "$users is not in group $exceptionGroup."
		fi
	done

	# If users have 2FA Disabled verify counter.
	for users in ${disabled2FAUsers[@]}; do
		# If disabled 2FA User has been notified & is in Exception Group; remove from exception group.
		if [[ "$(verifyNotificationCounter $users)" > $notificationCap
		&& `gam print groups member $users | grep $exceptionGroup` ]]; then
			echo "$users notificaiton counter is greater than $notificationCap & member needs to be removed from $exceptionGroup."
			gam update group $exceptionGroup remove user $users
		else
			echo "$users have not been notified. Do nothing."
		fi
	done
	echo ""
}

# Disabled 2FA; Notify Users + Add Notification Counter

#gam update user zz_testing Automation.2FA_Notifications 0
