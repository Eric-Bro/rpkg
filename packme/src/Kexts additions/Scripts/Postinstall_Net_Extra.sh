#!/bin/sh

if [ -e ${3}[_tmp_folder_] ]; then
echo ""
else 
exit -1
fi

if [ -e ${3}/Extra/Extensions ]; then
path="${3}/Extra/Extensions"
fi

if [ -e ${3}/efi/kext ]; then 
osver=`sed -n '14p;14q' /System/Library/CoreServices/SystemVersion.plist`
osver=${osver:9:4}
path="${3}/efi/kext/${osver}"
fi

if [ -e ${3}[_tmp_folder_] ]; then
 rootkextpluginsdir="[_root_kext_]/Contents/PlugIns"
fi


sudo cp -a ${3}[_tmp_folder_]/[_bundlename_] ${path}/${rootkextpluginsdir}/

sudo rm -R ${3}[_tmp_folder_]

sudo chflags -R -H hidden ${3}/usr