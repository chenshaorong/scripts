#!/bin/bash
# Author: csr
# Date：2016-03-27
# Email: 731685435@qq.com
# Version: v1.0
#
# Usage:
#   * 统计每小时分钟秒行数
#   * ./statistics_time.sh -t file
#
# [OPITION]
#   -h 显示帮助信息
#   -s file 按秒统计
#   -m file 按分钟统计
#   -t file 按半小时统计
#   -o file 按小时统计

export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

. stderr.sh

while getopts ":s:m:t:o:h" value; do
	case $value in
		h)
			echo -e "\033[36mUsage:\n  -s second\n  -m minute\n  -t half hour\n  -o one hour\033[0m"
			;;
		s)
			perl -e 'while(<>){$hash{$1}++ if /\D(\d\d:\d\d:\d\d)\D/;} while(($key,$value) = each %hash){print "$key $value\n"}' $OPTARG |sort
			;;
		m)
			perl -e 'while(<>){$hash{$1}++ if /\D(\d\d:\d\d):\d\d\D/;} while(($key,$value) = each %hash){print "$key $value\n"}' $OPTARG |sort
			;;
		t)
			perl -e 'while(<>){if(/\D(\d\d):(\d\d):\d\d\D/ and $2>=30){$hash{$1.":30 ~ ".$1.":59"}++;}else{$hash{$1.":00 ~ ".$1.":30"}++;}} while(($key,$value) = each %hash){print "$key $value\n"}' $OPTARG |sort
			;;
		o)
			perl -e 'while(<>){$hash{$1}++ if /\D(\d\d):\d\d:\d\d\D/;} while(($key,$value) = each %hash){print "$key $value\n"}' $OPTARG |sort
			;;
		?)
			err "$0: Invalid option, -h for help"
			exit 1
			;;
	esac
done
