#!/bin/bash

#/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -help

JHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
title="This is Title"
heading="This is Heading"
description="This is Description"
iconPath=""
button1="Button 1"
button2="Button 2"
defaultButton=""
cancelButton=""
delayOptions="0, 60, 120, 600, 1800, 3600"


#"${JHelper}" -help


"${JHelper}" -windowType hud -title "${Title}" -heading "${heading}" -description "${description}" -button1 "${button1}" -button2 "${button2}"