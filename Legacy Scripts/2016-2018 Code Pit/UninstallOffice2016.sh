#!/bin/bash

# This script removes all Office 2016 files from the device including user-specific settings for all apps.

# Kill any Microsoft apps forcefully.
pkill -f Microsoft

for user in $(dscl . list /Users UniqueID | awk '$2 >= 500 {print $1}'); do
	userHome=$(dscl . read /Users/"$user" NFSHomeDirectory | sed 's/NFSHomeDirectory://' | grep "/" | sed 's/^[ \t]*//')
	echo "$user:$userHome"

	# Build the list of dirs to remove.
	directories=(
	# Applications
	"/Applications/Microsoft Excel.app"
	"/Applications/Microsoft OneNote.app"
	"/Applications/Microsoft Outlook.app"
	"/Applications/Microsoft PowerPoint.app"
	"/Applications/Microsoft Word.app"
	# User Preferences
	"$userHome/Library/Containers/com.microsoft.errorreporting"
	"$userHome/Library/Containers/com.microsoft.Excel"
	"$userHome/Library/Containers/com.microsoft.netlib.shipassertprocess"
	"$userHome/Library/Containers/com.microsoft.Office365ServiceV2"
	"$userHome/Library/Containers/com.microsoft.Outlook"
	"$userHome/Library/Containers/com.microsoft.Powerpoint"
	"$userHome/Library/Containers/com.microsoft.RMS-XPCService"
	"$userHome/Library/Containers/com.microsoft.Word"
	"$userHome/Library/Containers/com.microsoft.onenote.mac"
	# Outlook Data
	"$userHome/Library/Group Containers/UBF8T346G9.ms"
	"$userHome/Library/Group Containers/UBF8T346G9.Office"
	"$userHome/Library/Group Containers/UBF8T346G9.OfficeOsfWebHost"
	)

	# Iterate through all the directories and attempt removing them.
	for dir in "${directories[@]}"
	do
		if [ -e "${dir}" ]; then
			rm -rf "${dir}"
			echo "Removed directory: ${dir}"
		else
			echo "Directory not found: ${dir}"
		fi
	done
done
