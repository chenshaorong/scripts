#!/usr/bin/env perl
# Author: csr
# Date：2016-01-15
# Email: chenshaorong@oschina.cn
# Version: v5.2
#
# 前提：经常会遇到这种情况：系统出问题了但是却找不出根源
# 该脚本则用于每n秒对比下，查看哪些进程发生了变化
#
# Usage:
#   - ./diffps.pl n 间隔ns刷新一次，默认为3s
#   - ctrl+c暂停，直接回车或输入'q'、'quit'退出(输入其他表示继续)
#
# 打印格式：(最后一个用于确定命令其绝对路径)
#   - pid ppid cmd `stat /proc/$pid/cwd |head -1`
#   - 全：打印出前后两次所有不同进程的
#   - 1 : 打印消失的进程
#   - 2 : 打印增加的进程
# 例如：
# csr@ubuntu:~$ ./ps_diff.pl n
# 补集-全
#  7189 6375     /bin/sleep 10
#  8139 8137     /usr//sbin/zabbix_server: configuration syncer [synced configuration in 0.013953 sec, idle 60 sec]
#  8139 8137     /usr//sbin/zabbix_server: configuration syncer [synced configuration in 0.013934 sec, idle 60 sec]
# 补集-1
#  8139 8137     /usr//sbin/zabbix_server: configuration syncer [synced configuration in 0.013953 sec, idle 60 sec]
# 补集-2
#  7189 6375     /bin/sleep 10
#  8139 8137     /usr//sbin/zabbix_server: configuration syncer [synced configuration in 0.013934 sec, idle 60 sec]
#
# Tip: 如果只是简单的观察可以这样
#   - ps -ef >/tmp/ps1.txt; sleep 5; ps -ef >/tmp/ps2.txt; # 每隔5s收集下数据并保存至/tmp下
#   - sort /tmp/ps1.txt /tmp/ps2.txt |uniq -u # 排序并只打印出不重复的行(相当于这里的补集全了)
# 如果还想知道哪些进程消失或增加了可以这样
#   - ps -ef |sort >/tmp/ps1.txt; sleep 5; ps -ef |sort >/tmp/ps2.txt
#   - 全：comm /tmp/ps1.txt /tmp/ps2.txt -3
#   - 消失的进程(ps1的差集)
#     * comm /tmp/ps1.txt /tmp/ps2.txt -2 -3
#   - 增加的进程(ps2的差集)
#     * comm /tmp/ps1.txt /tmp/ps2.txt -1 -3

#use strict;
use warnings;

sub sig_handler {
    chomp(my $in=<STDIN>);
    exit 0 if $in eq '' || $in eq 'q' || $in eq 'quit';
}

$SIG{INT}=\&sig_handler;

system("clear");

# 默认间隔时间等于3s
our $seq=3;
# 判断$1是否为合法数字且大于0
$seq=$ARGV[0] if 0 < @ARGV && $ARGV[0] =~ /^-?\d+(\.\d+)?$/ && $ARGV[0] !~ /^-?0(\d+)?$/ && $ARGV[0] > 0;

# perl和shell一样，双引号内需要对 $ 进行转义，而单引号则不用
#   - 这里要注意：`ps -ef |awk '{print \$NF}'`
#   - 还是需要对$NF进行转义，因为在 `` 里 单引号 只是做普通的字符串
# 注释的三行效果和没注释的那行执行的效果是一样的
#$c1="ls -ld /proc/";
#$c2="/cwd |awk '{print \\\$NF}'";
#@res=`ps -ef |sed '1'd | awk -F' ' '{ORS="    path: "; if(\$2!='$$' && \$3!=$$ && \$2!='\$\$' && \$3!='\$\$'){\$1=\$4=\$5=\$6=\$7=""; print; system("'"$c1"'"\$2"'"$c2"'")}}'`;
our @res1=`ps -ef |sed '1'd | awk -F' ' '{ORS="    path: "; if(\$2!='$$' && \$3!=$$ && \$2!='\$\$' && \$3!='\$\$'){\$1=\$4=\$5=\$6=\$7=""; print; system("'"ls -ld /proc/"'"\$2"'"/cwd |awk '{print \\\$NF}'"'")}}'`;
our @res2;
our %m;
our %n;

while(1){
    sleep $seq;
    system("clear");
    @res2=`ps -ef |sed '1'd | awk -F' ' '{ORS="    path: "; if(\$2!='$$' && \$3!=$$ && \$2!='\$\$' && \$3!='\$\$'){\$1=\$4=\$5=\$6=\$7=""; print; system("'"ls -ld /proc/"'"\$2"'"/cwd |awk '{print \\\$NF}'"'")}}'`;
    
    # 并集、交集
    for(@res1,@res2){
        $m{$_}++ && $n{$_}++;
    }
    #@binji=keys %m; # value=0 1 2
    #@union=keys %n; # value=0 1
    
    # 补集-全
    print "补集-全\n";
    foreach(keys %m){
        print unless (exists($n{$_}) && $n{$_}==1);
    }
    
    # 补集-1
    print "补集-1\n";
    foreach(@res1){
        print unless (exists($n{$_}) && $n{$_}==1);
    }
    
    # 补集-2
    print "补集-2\n";
    foreach(@res2){
        print unless (exists($n{$_}) && $n{$_}==1);
    }

    %m=();
    %n=();
    @res1=@res2;
}
