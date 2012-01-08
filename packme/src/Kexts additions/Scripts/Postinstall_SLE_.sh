#!/bin/sh

osver = `sed -n '14p;14q' /System/Library/CoreServices/SystemVersion.plist`
osver = ${osver:12:1}

if [ -e ${3}[_tmp_folder_] ]; 
then
	sudo cp -a -f ${3}[_tmp_folder_]/[_bundlename_] ${3}/System/Library/Extensions/
	sudo chown -R root:wheel ${3}/System/Library/Extensions/[_bundlename_]
	sudo chmod -R 755 ${3}/System/Library/Extensions/[_bundlename_]
	sudo rm -R ${3}[_tmp_folder_]
else 
	exit 0
fi

if [ $osver > 6 ]; then
  sudo rm ${3}/System/Library/Caches/com.apple.kext.caches/Startup/kernelcache
  sudo kextcache -K /mach_kernel -prelinked-kernel ${3}/System/Library/Caches/com.apple.kext.caches/Startup/kernelcache ${3}/System/Library/Extensions
else 
  sudo rm ${3}/System/Library/Caches/com.apple.kext.caches/Startup/Extensions.mkext
  sudo kextcache -v 1 -a i386 -a x86_64 -m ${3}/System/Library/Caches/com.apple.kext.caches/Startup/Extensions.mkext -z ${3}/System/Library/Extensions
fi

sudo chflags -R -H hidden ${3}/usr
exit 0