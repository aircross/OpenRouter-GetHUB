#!/bin/bash
#卓微科技@limeng

start() {
	enable=$(uci get database.config.enable)
	user_name="root"
	passwd=$(uci get database.config.passwd)
	start_server=$(uci get database.config.server_start)
	database_name=$(uci get database.config.database_name)
	
	device=$(uci get database.config.device)
	point="`mount | grep "$device" | awk '{print $3}'`"
	
	[ "$passed" != "" ] || passwd="openrouter"
	[ "$database_name" != "" ] || database_name="openrouter"
	
	if [ "$enable" == "1" ]; then
		sed -r -i "s#(.*)(/mnt/sd..)(.*)#\1$point\3#g" /etc/php.ini  
		sed -r -i "s#(.*)(/mnt/sd..)(.*)#\1$point\3#g" /etc/my.cnf
		sed -r -i "s#(.*)(/mnt/sd..)(.*)#\1$point\3#g" /etc/nginx/nginx.conf
		
		sed -r -i "s#(.*)(/dev/sd..)(.*)#\1$point\3#g" /etc/php.ini  
		sed -r -i "s#(.*)(/dev/sd..)(.*)#\1$point\3#g" /etc/my.cnf
		sed -r -i "s#(.*)(/dev/sd..)(.*)#\1$point\3#g" /etc/nginx/nginx.conf
	
		if [ ! -d $point/data/tmp ]; then
			/etc/init.d/mysqld restart
			sleep 2;
			mkdir -p $point/data $point/data/mysql $point/data/tmp
			/usr/bin/mysql_install_db --force
			/etc/init.d/mysqld restart
			sleep 3;
			/usr/bin/mysqladmin -u $user_name password $passwd
			db=`mysql -u $user_name -p$passwd <<EOF
create database $database_name
\g
exit
EOF`
			echo $db
		fi
	fi
	
	if [ "$start_server" == "1" ]; then
		/usr/bin/spawn-fcgi -a 127.0.0.1 -p 9000 -C 2 -f /usr/bin/php-cgi
		/etc/init.d/nginx restart
	fi
}

stop() {
	/etc/init.d/nginx stop
}

start;