#!/bin/bash

# Ends with success (green) if the device has a SSD as the boot drive.
# Exits with failure (red) if not an SSD.

if diskutil info / 2>/dev/null | grep 'Solid State' | grep 'Yes'; then
	exit 0
else
	exit 1
fi