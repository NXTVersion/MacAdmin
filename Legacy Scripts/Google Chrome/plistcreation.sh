#!/bin/bash

## --- HEADER --- ##
# Created By: Damian Finger
# Created On: 12/11/19
# Updated By: Damian Finger
# Updated On: 12/11/19
# Audited By: Damian Finger
# Audited On: 12/11/19
# Purpose Other Notes:
# Manage Google Chrome with a granular and modular script; creates plist, converts to profile, installs, profile
## --- ------ --- ##

# Main Function
function main(){
	# Required Functions
	Variables
	plistBase
	
	plistBase
	plistHomepage
	
	# Required Functions
	endPlist
}

# Variables used in functions below
function Variables {
	
}

# Create Base PLIST
function plistBase {
	echo "Creating Base Plist File..."
	cd /tmp/ && touch com.google.Chrome.plist

tee << EOF /tmp/com.google.Chrome.plist > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
EOF
}

# Set Chrome Homepage
function plistHomepage {
	homepage="https://www.pepofaz.com"
	
	if [ -z "$homepage" ]; then
		echo "No Homepage Selected"
	else
tee -a << EOF /tmp/com.google.Chrome.plist > /dev/null
	<key>HomepageLocation</key>
	<string>$homepage</string>
	<key>HomepageIsNewTabPage</key>
	<false/>
	<key>ShowHomeButton</key>
	<true/>
EOF
	fi
}

# End Plist
function endPlist {
tee -a << EOF /tmp/com.google.Chrome.plist > /dev/null
</dict>
</plist>
EOF
}

main "$@"