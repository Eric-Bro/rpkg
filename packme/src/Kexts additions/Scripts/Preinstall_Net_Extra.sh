#!/bin/sh


path="${3}/Extra/Extensions"

if [ -e ${path}/[_root_kext_] ]; 
then 
	echo ""
else 
	sudo cp -a -f /System/Library/Extensions/[_root_kext_] ${path}/ 	
fi

exit 0