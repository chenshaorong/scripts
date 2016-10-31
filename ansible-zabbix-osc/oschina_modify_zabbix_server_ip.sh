#!/bin/bash

export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

/usr/bin/perl -i -pe 's/2\.2\.2\.2/6.6.6.6/g' /etc/zabbix/zabbix_agentd.conf

# 如果启用了ufw，则添加zabbix_server IP白名单
if ! ufw status |grep -q 'inactive'; then
# 如果是iptables则还需要再判断一次IP是否已存在再添加，ufw不需要，因为他会自动跳过已存在的记录
    ufw allow from 6.6.6.6
fi

# 删除原zabbix_server IP
if ufw status |grep -q '2.2.2.2'; then
    ufw delete allow from 2.2.2.2
fi

service zabbix-agent restart
