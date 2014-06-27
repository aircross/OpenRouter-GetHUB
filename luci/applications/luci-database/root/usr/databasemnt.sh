#!bin/bash

device=$(uci get database.config.device)

grep "/dev/sd" /etc/mtab |cut -d " " -f 1 > /tmp/databasemnt
point=`cat "/tmp/databasemnt"`

#no point
[ -n "$point" ] || exit 1

#input point empty
[ -n "$device" ] || exit 2

#input point err
while read line
do
	[ "$device" == "$line" ] && exit 0
done < /tmp/databasemnt

exit 3

