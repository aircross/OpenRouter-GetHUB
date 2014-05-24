#!bin/bash
device=$(uci get xunlei.config.device)

#no point
grep "/dev/sd" /etc/mtab |cut -d " " -f 1 > /tmp/lmmntpoint
point=`cat "/tmp/lmmntpoint"`
[ -n "$point" ] || exit 1

#input point empty
[ -n "$device" ] || exit 2

#input point err
[ "$device" == "$point" ] || exit 3

exit 0

