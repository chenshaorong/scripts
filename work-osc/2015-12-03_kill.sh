#!/bin/bash
# Author: csr
# Date：2015-12-03
# Email: chenshaorong@oschina.cn
# Version: v3.1
# 前提：有时候某个(或某类)进程很多，手动kill太麻烦，故可以写个简单脚本批量kill
# 
# usage:
#   ./kill.sh args
# 
# [示例]
#   如kill大量的java、tomcat、sleep 100进程
#   ./kill.sh "java" "tomcat" "sleep 100"

for i in `seq 1 $#`; do
    argv=${!i}
    for pid in `ps -ef |grep "$argv" |grep -v grep |awk -F' ' '{if($2!='$$' && $3!='$$')print $2}'`; do  
        cmd=`ps -ef |awk -F' ' '{if($2=='$pid'){ORS=""; i=8; while(i<=NF){print $i" "; i++};}}'`
        kill -15 $pid && echo "kill pid{$pid} cmd{$cmd} ok."
    done
done
