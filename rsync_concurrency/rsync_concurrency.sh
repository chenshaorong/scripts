#!/bin/bash
# Author: csr
# Date：2015-12-03
# Email: chenshaorong@oschina.cn
# Version: v2.1

. rsync_concurrency.conf

echo "Start: `date`" > $rsync_log
trap 'for pid in `ps -ef |grep -E [r]sync.*'$rsync_des' |awk -F" " '"'{print \$2}'"'`; do kill -15 $pid && echo "kill $pid ok." &>> '$rsync_log'; done; echo "trap: `date`" >> '$rsync_log'; exit 0' INT

function run(){
	if [ -d $1 ] && [ ! -L $1 ]; then
		#rsync "$rsync_args" "$1" "$rsync_des" &> /dev/null
		rsync "$rsync_args" "$1" "$rsync_des" &>> $rsync_log
	fi
}

if ! echo $$ >$pid_file; then
	exit 1
fi

while getopts ":n:f:h" value; do
	case $value in
		h)
			echo -e "\033[36mREADME:\033[0m"
			echo -e "\033[36m`cat README`\033[0m"
			echo
			echo -e "\033[32m配置文件:\033[0m"
			echo -e "\033[32m`cat rsync_concurrency.conf`\033[0m"
			exit 0
			;;
		n)
			rsync_num=$OPTARG
			;;
		f)
			rsync_user_list=$OPTARG
			;;
		?)
			echo -e "\033[31mInvalid arg: -h to help\033[0m"
			exit 1
			;;
	esac
done

if [[ $rsync_num == *[!0-9]* ]]; then
	echo -e "\033[31mrsync_num is not a number.\033[0m"
	exit 2
fi

if [ ! -f $rsync_user_list ] || [ ! -r $rsync_user_list ]; then
	echo -e "\033[31m$rsync_user_list not a file or can't read.\033[0m"
	exit 1
fi

tmpfile="$$.fifo"
mkfifo $tmpfile
exec 6<>$tmpfile
rm -f $tmpfile

for i in `seq 1 $rsync_num`; do
	echo
done >&6

for user in `cat $rsync_user_list`; do
    read -u6
	{
 		run $user && {
  		  echo "$user rsync ok" &>> $rsync_log
        } || {
	      echo "$user rsync error" &>> $rsync_log
	    }
        echo >&6
    }&
done

wait
echo "End: `date`" >> $rsync_log

exec 6>&-
exit 0
