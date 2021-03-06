#!/bin/bash

LOGFILE=/tmp/updater.log
. /opt/engines/installers/routines.sh

 make_dirs
 
if test ! -f /tmp/updater.updated
then
	cd /opt/engines
	echo "Downloading changes"
	git pull >>$LOGFILE 
	touch /tmp/updater.updated
	echo "Applying changes"
	$0
	rm /tmp/updater.updated
	exit
fi


#Need to rebuild everything is generate_keys is run
if test $# -gt 0 
 then
 	if test $1 = "-k"
		then 
			generate_keys
	fi
fi

set_os_flavor

setup_mgmt_git
 

echo "Building Images"
 /opt/engines/bin/buildimages.sh >>$LOGFILE 
 
remove_services
create_services
set_permissions

 
#Fix me need to do a full regen here for all engines or atleast trigger notifcation it needs to be done.
docker stop mgmt
docker rm mgmt

echo "Building System Gui"
/opt/engines/bin/mgmt_startup.sh  >>$LOGFILE 
sleep 180
hostname=`hostname`
echo "Congratulations Engines OS is now up to date please go to https://${hostname}:88/"


 