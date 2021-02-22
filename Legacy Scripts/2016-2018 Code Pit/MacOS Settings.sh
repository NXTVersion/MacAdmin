#!/bin/bash

#Disable Guest User
defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false

#Enable Guest User
defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool true

#Disable Remote Access
echo "yes" | sudo systemsetup -setremotelogin off > /dev/null 2>&1

#Disable Show Remote Management Button
sudo defaults write /Library/Preferences/com.apple.RemoteManagement LoadRemoteManagementMenuExtra -bool false

#Enable Firewall
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

launchctl unload /System/Library/LaunchAgents/com.apple.alf.useragent.plist
launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist

launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist
launchctl load /System/Library/LaunchAgents/com.apple.alf.useragent.plist

#Enable GateKeeper
spctl --master-enable


