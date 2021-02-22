#!/bin/sh
# Script to create local user. Be sure to edit variables under "Modifiable Variables" - and return to original when complete

## MODIFIABLE VARIABLEs ##
USERNAME=elenawall
FULLNAME="Elena Wall"
PASSWORD=Simo9$

# Verify variables
echo "Variables have been set:"
echo "USERNAME = " $USERNAME
echo "FULLNAME = " $FULLNAME
echo "PASSWORD = " $PASSWORD

#Create User
echo "Creating user account now..."
sudo sysadminctl -addUser $USERNAME -fullName "$FULLNAME" -password $PASSWORD

#Run Bypass SetupAssistant script if viable
if [ -f /Library/Addigy/ansible/Scripts/BypassSetupAssistant.sh ]; then
echo "Running bypass Apple Setup Assistant Script"
sudo sh /Library/Addigy/ansible/Scripts/BypassSetupAssistant.sh
fi
