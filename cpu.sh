#!/bin/bash 
# PS: 网上下载的脚本

physicalNumber=0
coreNumber=0
logicalNumber=0
HTNumber=0
logicalNumber=$(grep "processor" /proc/cpuinfo|sort -u|wc -l)
physicalNumber=$(grep "physical id" /proc/cpuinfo|sort -u|wc -l)
coreNumber=$(grep "cpu cores" /proc/cpuinfo|uniq|awk -F':' '{print $2}'|xargs)
HTNumber=$((logicalNumber / (physicalNumber * coreNumber))) 
echo "****** CPU Information ******"
echo "Logical CPU Number  : ${logicalNumber}"
echo "Physical CPU Number : ${physicalNumber}"
echo "CPU Core Number     : ${coreNumber}"
echo "HT Number           : ${HTNumber}"
echo "*****************************"

# 补充内容：
# 查看CPU信息（型号）
# # cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c
#
# 查看主板型号：
# # dmidecode |grep -A16 "System Information$"
#
# 查看机器型号
# # dmidecode | grep "Product Name"
#
# dmidecode -s system-serial-number    查看序列号
#
# dmidecode  -t1 查看服务器型号

