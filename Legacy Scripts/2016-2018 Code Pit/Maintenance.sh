#!/bin/sh

#Clear Dyname Linker
update_dyld_shared_cache -force

#Clear Font Cache
atsutil databases -remove
pkill fontd

#Clear Software Update Catalog
softwareupdate --clear-catalog

#Clear TMP Folder
rm -rf /tmp/*

#Delete SpinDump
rm -rf /var/db/spindump/*

#FlushDNS
killall -HUP mDNSResponder && dscacheutil -flushcache

#MacOS Maintenance Scripts
sudo periodic daily weekly monthly