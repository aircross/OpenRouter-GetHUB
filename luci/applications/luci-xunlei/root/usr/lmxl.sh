#!bin/bash

device=$(uci get xunlei.config.device)

grep "/dev/sd" /etc/mtab |cut -d " " -f 1 > /tmp/lmmntpoint
point=`cat "/tmp/lmmntpoint"`

#no point
[ -n "$point" ] || exit 1

#input point empty
[ -n "$device" ] || exit 2

#input point err
while read line
do
	[ "$device" == "$line" ] && exit 0
done < /tmp/lmmntpoint

exit 3

