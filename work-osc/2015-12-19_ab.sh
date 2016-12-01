#!/bin/bash
# Author: csr
# Date：2015-12-19
# Email: chenshaorong@oschina.cn
# Version: v1.0
# 详解：
#   url.txt 中存放需要并发的url
#   $1 表示并发数
#   $2 表示总请求数
#   $3 表示url的并发数(如100条url $3=10，即单位时间内只有10条并发)
# Tip: 单位时间总并发数=$1*$3; 总请求数=$2*count(url.txt)
# Stop: kill -2 pid

trap 'for pid in `ps -ef |grep " a[b] -c " |awk -F" " '"'{print \$2}'"'`; do kill -15 $pid && echo "kill $pid ok."; done; exit 0' INT

tmpfile="$$.fifo"
mkfifo $tmpfile
exec 6<>$tmpfile
rm -f $tmpfile

for i in `seq 1 $3`; do
        echo
done >&6

i=1
for url in `cat url.txt`; do
	read -u 6
    {
        ab -c $1 -n $2 $url &> url${i}.log 
        echo >&6
    } &> /dev/null &
    i=$(($i+1))
done

wait
