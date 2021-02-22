#!/bin/sh
##########
## Script: EnableARDSSHSpecificUsers.sh
## CreatedBy: Damian Finger
## CreationDate: 01/29/19
## ModifiedDate: 01/29/19
## Purpose:
## This script checks for the existence of admin accounts: admin, USERACCOUNT. Then adds these accounts to the ARD access group, verifies the addition of these accounts; if the accounts do not get added to the group for some reason, the script will enable ARD for all users and return an error.
## This script also enables SSH for administrators
## This is for best practice security to limit the users who can access the system. However, the addition of enabling ARD for all users if no user has access is against security best practices
##### END OF HEADER #####


# Function to join Array variables with commas
function joinwith { local IFS="$1"; shift; echo "$*"; }

# Variables
declare -a USERARRAY

# Enable SSH for Administrator group
echo "Turning on SSH..."
sudo dseditgroup -o create -q com.apple.access_ssh
sudo dseditgroup -o edit -a admin -t group com.apple.access_ssh
sudo systemsetup -setremotelogin on

# If ARD settings are already correct, exit
if [[ $(dscl . -list /Users dsAttrTypeNative:naprivs | grep USERACCOUNT) ]]; then
 echo "ARD settings are already set"
 exit 0
fi

#Determine Users to add to ARD
echo "Checking for users..."
if [ -d /Users/USERACCOUNT/ ]; then
	echo "Adding user USERACCOUNT to array variable"
	USERARRAY=("${USERARRAY[@]}" "USERACCOUNT")
fi
if [ -d /Users/admin/ ]; then
	echo "Adding user admin to array variable"
	USERARRAY=("${USERARRAY[@]}" "admin")
fi

# Create list of users seperated by commas
USERLIST=`joinwith , ${USERARRAY[@]}`
echo "List of users in array variable are: $USERLIST"

# Enable ARD for Specific Users turned ON
echo "Turning ARD on for specific users..."
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -allowAccessFor -specifiedUsers

# Add users to ARD list
echo "Adding the following user to ARD list: $USERLIST"
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -access -on -privs -all -users "${USERLIST}"

# Verify users are listed in ARD; if none, enable ARD for all

if [[ $(dscl . -list /Users dsAttrTypeNative:naprivs) ]]; then
	echo "The list of users in allowed in ARD are: "
	dscl . -list /Users dsAttrTypeNative:naprivs
else
	echo "There are no users in specific users list. Enabling ARD for all users"
	sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -allowAccessFor -allUsers -privs -all -clientopts -setmenuextra -menuextra yes
fi
