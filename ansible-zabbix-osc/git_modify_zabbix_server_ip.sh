#!/bin/bash

export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

/usr/bin/perl -i -pe 's/1\.1\.1\.1/192.168.2.66/g' /etc/zabbix/zabbix_agentd.conf

# 判断并添加ufw内网端白名单
if ! ufw status |grep -q '192.168.2'; then
# 如果是iptables则还需要再判断一次IP是否已存在再添加，ufw不需要，因为他会自动跳过已存在的记录
    ufw allow from 192.168.2.0/24
fi

# 删除原zabbix_server IP
if ufw status |grep -q '1.1.1.1'; then
    ufw delete allow from 1.1.1.1
fi

service zabbix-agent restart
