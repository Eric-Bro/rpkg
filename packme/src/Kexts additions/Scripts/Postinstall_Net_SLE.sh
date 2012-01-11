#!/bin/sh

if [ -e ${3}[_tmp_folder_] ]; then
rootkextpluginsdir="[_root_kext_]/Contents/PlugIns"
sudo cp -a -f ${3}[_tmp_folder_]/[_bundlename_] ${3}/System/Library/Extensions/${rootkextpluginsdir}/
osver=`sed -n '14p;14q' /System/Library/CoreServices/SystemVersion.plist`
osver=${osver:12:1}

sudo chown -R root:wheel ${3}/System/Library/Extensions/${rootkextpluginsdir}/[_bundlename_]
sudo chmod -R 755 ${3}/System/Library/Extensions/${rootkextpluginsdir}/[_bundlename_]
sudo rm -R ${3}[_tmp_folder_]
sudo chflags -H hidden ${3}/usr

if [ $osver > 6 ]; then
sudo rm ${3}/System/Library/Caches/com.apple.kext.caches/Startup/kernelcache
sudo kextcache -K /mach_kernel -prelinked-kernel ${3}/System/Library/Caches/com.apple.kext.caches/Startup/kernelcache ${3}/System/Library/Extensions
else
sudo rm ${3}/System/Library/Caches/com.apple.kext.caches/Startup/Extensions.mkext
sudo kextcache -v 1 -a i386 -a x86_64 -m ${3}/System/Library/Caches/com.apple.kext.caches/Startup/Extensions.mkext -z ${3}/System/Library/Extensions
fi

else
exit 1
fi