#!/bin/bash

#/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -help

JHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
title="Restart Required"
heading="Restart Required"
description="An update has been applied to your system. Please restart your computer when you are available. 

IT Support - HelpDesk@pepofaz.com"
iconPath=""
button1="Restart Now"
button2="Delay Restart"
defaultButton=`open -a Safari.app`
cancelButton=""
delayOptions="0, 60, 120, 600, 1800, 3600"


#"${JHelper}" -help


"${JHelper}" -windowType hud -title "${Title}" -heading "${heading}" -description "${description}" -button1 "${button1}" -button2 "${button2}"