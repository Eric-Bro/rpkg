#!/bin/sh


if [ -e ${3}/Extra/Extensions ]; then
  path="${3}/Extra/Extensions"
fi

if [ -e ${3}/efi/kext ]; then 
osver=`sed -n '14p;14q' /System/Library/CoreServices/SystemVersion.plist`
osver=${osver:9:4}
  path="${3}/efi/kext/${osver}"
fi


if [ -e ${path}/[_root_kext_] ]; 
then 
	echo ""
else 
	sudo cp -a /System/Library/Extensions/[_root_kext_] ${path}/ 	
fi

exit 0