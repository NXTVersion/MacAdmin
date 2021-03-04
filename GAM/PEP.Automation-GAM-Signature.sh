#!/bin/bash

## --- HEADER --- ##
# Created By: Damian Finger
# Created On: 04/01/20
# Updated By: Damian Finger
# Updated On: 04/16/20
# Audited By: Damian Finger
# Audited On: 04/03/20
# Purpose Other Notes:
# Automatically configure and setup Google Mail signatures for employees in the PEPofAZ/Users/ Organizational Unit
## --- ------ --- ##

# Function for Variables
function VARIABLES {
	# Editable Variables
	docPath="/Users/Shared"		#Path to store Signature Template & Users CSV
	usersOU="/PE/Users"	#OU containing active users
}

function BACKUP {
	echo "Backing up current signratures to $docPath/'Signature Backup.txt'..."
	# Backup current signatures of all users
	/usr/local/bin/gam all users show signature format > $docPath/"Signature Backup.txt"
}

function CREATEDOCS {
	echo "Creating .csv of all users in $userOU..."
	# Create .CSV of all users in $userOU to file path location $docPath
	/usr/local/bin/gam print users allfields query "orgUnitPath=$usersOU" > "$docPath"/GoogleUsers.csv
	
	echo "Creating Signature Template..."
	# Create Signature template .TXT to file path location $docPath
	{
		echo "{Name}"
		echo "{Title}"
		echo "Company Name"
		echo "Company Address"
		echo "P 480-999- | F 480-94 | C {workphone}"
		echo "{email}"
	} >"$docPath"/Automation-GAM-Signature.txt
}

function SETSIG {
	echo "Setting signatures of all users in $usersOU from Signature template...."
	# Set signatures based on .csv and .txt files located at $docPath
	/usr/local/bin/gam csv "$docPath"/GoogleUsers.csv gam user "~primaryEmail" signature file "$docPath"/Automation-GAM-Signature.txt replace "Name" "~name.fullName" replace "Title" "~organizations.0.title" replace "workphone" "~phones.0.value" replace "email" "~primaryEmail"
}

main() {
	BACKUP
	VARIABLES
	CREATEDOCS
	SETSIG
}

main "$@"

# Missing Functions:
# - Verify GAM Installation

# Errors:
# - User does not have signature service (no gmail?)

