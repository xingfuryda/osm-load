#!/bin/sh

##
# Run osm2pgsql
#

runimport() {
	echo "Sleeping for 20 seconds to allow database init"
	sleep 20
	
	wget $PBF_URL -O download.osm.pbf
	export PGPASSWORD=password1

	osm2pgsql \
		--create \
		--slim \
		--hstore \
		--cache $OSM_IMPORT_CACHE \
		--number-processes 8 \
		--database gis \
		--username postgres \
		--host store \
		--port 5432 \
		download.osm.pbf
		
	echo "osm2pgsql import complete. Hit Ctrl-C to quit."
}

_wait () {
    WAIT=$1
    NOW=`date +%s`
    BOOT_TIME=`stat -c %X /etc/container_environment.sh`
    UPTIME=`expr $NOW - $BOOT_TIME`
    DELTA=`expr 5 - $UPTIME`
    if [ $DELTA -gt 0 ]
    then
	sleep $DELTA
    fi
}

# Unless there is a terminal attached wait until 5 seconds after boot
# when runit will have started supervising the services.
if ! tty --silent
then
    _wait 5
fi

# Execute the specified command sequence
for arg 
do
    $arg;
done

# Unless there is a terminal attached don't exit, otherwise docker
# will also exit
if ! tty --silent
then
    # Wait forever (see
    # http://unix.stackexchange.com/questions/42901/how-to-do-nothing-forever-in-an-elegant-way).
    tail -f /dev/null
fi
