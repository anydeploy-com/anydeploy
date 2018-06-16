#!/bin/bash

while true; do
	DATE=`date +%Y%m%d`
	HOUR=`date +%H`
	mkdir $WEBDIR/"$DATE"

	while [ $HOUR -ne "00" ]; do
		DESTDIR=$WEBDIR/"$DATE"/"$HOUR"
		mkdir "$DESTDIR"
		mv $PICDIR/*.jpg "$DESTDIR"/
		sleep 3600
		HOUR=`date +%H`
	done
done
