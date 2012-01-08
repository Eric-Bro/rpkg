#!/bin/sh

if [ -e ${3}[_tmp_folder_] ]; then
	echo ""
else 
	exit -1
fi

path="${3}/Extra/Extensions"
rootkextpluginsdir="[_root_kext_]/Contents/PlugIns"


sudo cp -a -f ${3}[_tmp_folder_]/[_bundlename_] ${path}/${rootkextpluginsdir}/

sudo rm -R ${3}[_tmp_folder_]

sudo chflags -R -H hidden ${3}/usr