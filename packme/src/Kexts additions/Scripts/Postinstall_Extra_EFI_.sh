#!/bin/sh

osver = `sed -n '14p;14q' /System/Library/CoreServices/SystemVersion.plist`
osver = ${osver:9:4}

if [ -e ${3}[_tmp_folder_] ]; then 
	echo ""
else 
	exit 1
fi

if [ -e ${3}/Extra/Extensions ]; then
sudo cp -a ${3}[_tmp_folder_]/[_bundlename_] ${3}/Extra/Extensions/
fi

if [ -e ${3}[_efi_folder_] ]; then 
sudo cp -a ${3}[_tmp_folder_]/[_bundlename_] ${3}[_efi_folder_]/${osver}/ 
fi

sudo rm -R ${3}[_tmp_folder_]
sudo chflags -R -H hidden ${3}/usr

exit 0