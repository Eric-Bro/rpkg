#!/bin/sh
if [ -e ${3}[_tmp_folder_] ]; then 
	echo ""
else 
	exit 1
fi

sudo cp -a -f ${3}[_tmp_folder_]/[_bundlename_] ${3}/Extra/Extensions/
sudo rm -R ${3}[_tmp_folder_]
sudo chflags -R -H hidden ${3}/usr

exit 0