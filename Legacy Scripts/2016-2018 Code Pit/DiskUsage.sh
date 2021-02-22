#!/bin/sh
# Determes where all their hard drive space has gone, this script leverages du and outputs text files of the top 75 directories of the root volume. The utilitarian results are sorted by size, in gigabytes, and saved to /tmp/DiskUsage/.
#####

#Variables
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
loggedInUserHome=`dscl . -read /Users/$loggedInUser | grep NFSHomeDirectory: | cut -c 19- | head -n 1`
machineName=`scutil --get LocalHostName`

#Output to Log File
/bin/echo "`now` *** Calculate Disk Usage for / ***" > /tmp/$machineName-ComputerDiskUsage.txt

/usr/bin/du -axrg / | sort -nr | head -n 75 > /tmp/$machineName-ComputerDiskUsage.txt

exit 0
exit 1