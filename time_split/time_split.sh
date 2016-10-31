#!/bin/bash 
# Author: csr 
# Date：2016-03-27
# Email: 731685435@qq.com
# Version: v2.4

export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

. ../stderr.sh

while getopts ":f:s:e:m:hv" value; do
    case $value in
        h)
			# '-': ignore "^\t*"
            cat <<-EOF
			[OPTION]:
			  * -s start time (format: 2 02 2:0 2:0:0 18 18:00 18:00:00 21:04 21:4)
			  * -e end time
			  * -f file (read from stdin if -f option not appoint)
			    * usually used with pipes if -f option not appoint
			  * -m mode: g=global, f=fast(default)
			  * -h for help
			  * -v for help(colors)

			[Usage]: [start,end)
			  * example1: show all(default 00:00:00-24:00:00)
			  *   $ $0 -f file
			  * example2: log is cut every day, grep 13:45:37-22
			  *   $ $0 -f file -s 13:45:37 -e 22
			  * example3: grep 2012-6-1 02:00:00-05:04:00
			  *   $ grep '2012-06-01' file |$0 -s 2 -e 5:4
			  * example4: (sto1) grep kern.log 2016-06-16 [start,end)
			  *   $ grep ' 16 ' /var/log/kern.log |grep -v 'UFW BLOCK' |$0 -s 16:40:20 -e 17:30 |less
			  *   $ grep ' 16 ' /var/log/kern.log |grep -v 'UFW BLOCK' |$0 -s 16:40:20 -e 17:30 |wc -l
			  *   1153
			  *   $ grep ' 16 ' /var/log/kern.log |grep -v 'UFW BLOCK' |$0 -s 16:40:25 -e 17:30 |wc -l
			  *   1126
			  * example5: mode global vs fast
			  *   $ grep -v 'UFW BLOCK' /var/log/kern.log |./time_split.sh -s 16:40:20 -e 17:30 # none (because nothing match in first day)
			  *   $ grep -v 'UFW BLOCK' /var/log/kern.log |./time_split.sh -s 16:40:20 -e 17:30 -m global
			  *   Jun 16 17:05:43 csr kernel: [379040.997305] e1000: eth0 NIC Link is Down
			  *   Jun 16 17:05:47 csr kernel: [379045.009975] e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
			  *   Jun 16 17:28:12 csr kernel: [380390.836134] e1000: eth0 NIC Link is Down
			  *   Jun 16 17:28:18 csr kernel: [380396.858125] e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
			  *   Jun 21 16:47:16 csr kernel: [488620.658329] e1000: eth0 NIC Link is Down
			  *   Jun 21 16:47:28 csr kernel: [488632.718334] e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
			EOF

            exit 0
            ;;
        v)
            echo -ne "\033[36m"
            # {s/\$0/'"$0"'/} => {s#\$0#'"$0"'#}, because $0 may has '/'
            perl -e '$f=0; while(<>){$f=1 if /^\s*cat <<-EOF\s*$/; $f=0 if /^\s*EOF\s*/; if($f==1 and ! /^\s*cat <<-EOF\s*$/){s/^\t+//; s#\$0#'"$0"'#; print}}' "$0"
            echo -ne "\033[0m"
            exit 0
            ;;
		m)
			# mode: g=global, l=local
			MODE=$OPTARG
			;;
        f)
            FILE=$OPTARG
            ;;
        s)
            # set s_h, s_m, s_s values(default): 0

			# Bug: echo "1" |awk -F':' '{print $1}'  display: null
			# s_h=`echo $OPTARG |awk -F':' '{print $1}'`
			s_h=$(echo "$OPTARG" |cut -d':' -f1)
            s_h=${s_h:-"0"}

            # Bug: echo "1" |cut -d: -f2  display: 1
            # s_h=`echo $OPTARG |cut -d':' -f2`
			s_m=$(echo "$OPTARG" |awk -F':' '{print $2}')
            s_m=${s_m:-"0"}

			s_s=$(echo "$OPTARG" |awk -F':' '{print $3}')
            s_s=${s_s:-"0"}

			sta=$(echo "$s_h*3600+$s_m*60+$s_s" |bc)
            ;;  
        e)  
			e_h=$(echo "$OPTARG" |cut -d':' -f1)
            e_h=${e_h:-"0"}
			e_m=$(echo "$OPTARG" |awk -F':' '{print $2}')
            e_m=${e_m:-"0"}
			e_s=$(echo "$OPTARG" |awk -F':' '{print $3}')
            e_s=${e_s:-"0"}
            end=$(echo "$e_h*3600+$e_m*60+$e_s" |bc)
            ;; 
        ?)
            err "Invalid option, -h for help, -v for help(colors)."
            exit 1
            ;;
    esac
done

# set default $start and $end time, 00:00:00-24:00:00(not use -s, -e option)
sta=${sta:-"0"}
end=${end:-"86400"}
# err $sta $end
MODE=${MODE:-"fast"}

# Example: 23:49:35-00:30:00 => 00:00:00-00:30:00
if [[ "$sta" > "$end" ]]; then
	sta=0
fi

# (default)read log from stdin if not use -f option
if [ -z "${FILE+xxx}" ]; then
    if [ "$MODE" == "g" ] || [ "$MODE" == "global" ]; then
        perl -e 'while(<STDIN>){print if /\D(\d\d):(\d\d):(\d\d)\D/ and $1*3600+$2*60+$3 >= '"$sta"' and $1*3600+$2*60+$3 < '"$end"'}'
    elif [ "$MODE" == "f" ] || [ "$MODE" == "fast" ]; then
        perl -e 'while(<STDIN>){if(/\D(\d\d):(\d\d):(\d\d)\D/){last if $1*3600+$2*60+$3 >= '"$end"'; print if $1*3600+$2*60+$3 >= '"$sta"'} }'
    fi
elif [ ! -f "$FILE" ]; then
    err "No such file"
else
    if [ "$MODE" == "g" ] || [ "$MODE" == "global" ]; then
        perl -ne 'print if /\D(\d\d):(\d\d):(\d\d)\D/ and $1*3600+$2*60+$3 >= '"$sta"' and $1*3600+$2*60+$3 < '"$end"' ' "$FILE"
    elif [ "$MODE" == "f" ] || [ "$MODE" == "fast" ]; then
        perl -ne 'if(/\D(\d\d):(\d\d):(\d\d)\D/){exit 0 if $1*3600+$2*60+$3 >= '"$end"'; print if $1*3600+$2*60+$3 >= '"$sta"'}' "$FILE"
    fi
fi
