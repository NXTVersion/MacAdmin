#!/bin/bash

userName=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
Serial=$(/usr/sbin/system_profiler SPHardwareDataType | awk '/Serial/ { print $NF }')
JH=$("/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper")

"/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper" -windowType utility -title "Update Username" -description "Your Username is $userName" -button1 "Thanks!" -button2 "Wait..." -defaultButton 1

curl -k -s -u jssadmin:jamf1234 -H "content-type: application/xml" https://192.168.3.245:8443/JSSResource/computers/serialnumber/"$Serial"/subset/location -d "<computer><location><username>"$userName"</username></location></computer>" -X PUT

exit 0
 