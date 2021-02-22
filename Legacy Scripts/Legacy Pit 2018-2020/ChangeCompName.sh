#!/bin/bash

## --- HEADER --- ##
# Created By: Damian Finger
# Created On: 09/20/19
# Updated By: Damian Finger
# Updated On: 09/20/19
# Audited By: Damian Finger
# Audited On: 09/20/19
# Purpose Other Notes:
# Script is to rename the computer based on the Company Abbreviated Name
# and the last 6 digits of the computer serial number
## --- ------ --- ##

# Main Function
function main(){
	setVariables
	setComputerName
}

## GLOBAL VARIABLES ##
function setVariables {
	# Current legged in user
	currentUser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
	# Company Abreviation Code
	companyShort="PEP"
	# Serial number to be parsed
	serialNumber=`ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}'`
	# Last 6 digits of Serial Number
	serial6=${serialNumber: -6}
}

# Function to set computer name
function setComputerName {
	newHostName=$companyShort-$serial6
	
	# If script not run as root; exit
	if [[ $EUID -ne 0 ]]; then
		/usr/bin/printf "This script must be run as root.\n"
		exit 1
	fi
	
	# If hostname is already set; exit
	if [ `hostname` = "$newHostName" ]; then
		/usr/bin/printf "Hostname has already been set"
		exit 1
	fi
	
	# Set computer name in all macOS components; Flush DNS
	/usr/sbin/scutil --set ComputerName "$newHostName"
	/usr/sbin/scutil --set HostName "$newHostName"
	/usr/sbin/scutil --set LocalHostName "$newHostName"
	/usr/bin/dscacheutil -flushcache
	
	# Verify computer name
	/usr/bin/printf "ComputerName='%s'\n" "$(/usr/sbin/scutil --get ComputerName)"
	/usr/bin/printf "HostName='%s'\n" "$(/usr/sbin/scutil --get HostName)"
	/usr/bin/printf "LocalHostName='%s'\n" "$(/usr/sbin/scutil --get LocalHostName)"

	# Update JAMF information
	jamf recon
}

# Run main function
main "$@"