# -*- coding: utf-8 -*-

"""
实时分析日志KEY速率工具

具体功能：
    pass

运行环境：
    Python 2.7.x

查看进程状态：
    top -Hcp `ps -ef |grep 'log_analyze.p[y]' |awk '{print $2}'`

运行程序：
    python log_analyze.py
    nohup python -u log_analyze.py >out.log 2>/dev/null &

输出KEY速率格式：
    2016-10-13 14:10:19 300 500 183.3.219.162 592
    时间戳 300s 500次 KEY=183.3.219.162 592次
    即在 xx~14:10:19 5分钟(300s)内 183.3.219.162 的次数为 592 > 500
"""

import time
import re
import logging.config
import ConfigParser
from collections import OrderedDict

logging.config.fileConfig('logging.conf')
logger = logging.getLogger("root")

cf = ConfigParser.ConfigParser()
cf.read("analyze.conf")

END_FLAG = int(cf.get('conf', 'END_FLAG'))
MAX_LEN = int(cf.get('conf', 'MAX_LEN'))
LOG = cf.get('conf', 'LOG')
WHITE_KEY = cf.get('conf', 'WHITE_KEY').split(',')

pattern_key = re.compile(cf.get('pattern', 'key'))
pattern_time = re.compile(cf.get('pattern', 'timestamp'))
pattern_filter = re.compile(cf.get('pattern', 'filter'))

regular_dict = OrderedDict()


def print_rate(tmp_timestamp):
    for i in range(len(cf.items('time'))):
        tmp_dict = {}
        speed = int(cf.items('speed')[i][1])
        tmp_time = int(cf.items('time')[i][1])
        for j in regular_dict.items()[MAX_LEN - tmp_time: MAX_LEN]:
            for k in j[1]:
                if k in tmp_dict:
                    tmp_dict[k] += j[1][k]
                else:
                    tmp_dict[k] = j[1][k]

        str_time = time.localtime(tmp_timestamp)
        str_time = time.strftime('%Y-%m-%d %H:%M:%S', str_time)
        for k in tmp_dict:
            if tmp_dict[k] >= speed:
                print str_time, tmp_time, speed, k, tmp_dict[k]


def main():
    tmp_timestamp = 0

    try:
        with open(LOG) as log:
            if END_FLAG == 1:
                log.seek(0, 2)

            while True:
                where = log.tell()
                line = log.readline()
                if not line:
                    time.sleep(1)
                    log.seek(where)
                    continue

                m = pattern_key.match(line)
                if not m:
                    logger.error(line.strip('\n') + ' << key no match >>')
                    continue
                key = m.group(1)
                if key in WHITE_KEY:
                    continue

                m = pattern_filter.search(line)
                if not m:
                    logger.info(line.strip('\n') + ' << filter not match >>')
                    continue

                m = pattern_time.match(line)
                if not m:
                    logger.error(line.strip('\n') + ' << time no match >>')
                    continue
                # shell: date +%s -d "2016-8-10 16:42:55"
                # timestamp = time.strptime('10, Aug, 2016, 16, 42, 55', '%d, %b, %Y, %H, %M, %S')
                timestamp = time.strptime(', '.join(m.groups()), '%d, %b, %Y, %H, %M, %S')
                timestamp = int(time.mktime(timestamp))

                # 初始化数据(如果MAX_LEN设置太大，则会卡死在这一步)
                if tmp_timestamp == 0:
                    tmp_timestamp = timestamp
                    for i in range(1, MAX_LEN)[::-1]:
                        regular_dict[timestamp - i] = {}
                    regular_dict[timestamp] = {}
                    regular_dict[timestamp][key] = 1
                    continue

                if tmp_timestamp == timestamp:
                    # <=> perl: regular_dict{timestamp}++
                    if key in regular_dict[timestamp]:
                        regular_dict[timestamp][key] += 1
                    else:
                        regular_dict[timestamp][key] = 1
                else:
                    print_rate(tmp_timestamp)

                    # 初始化间隔的时间 + 弹出最前面的数据
                    for i in range(tmp_timestamp + 1, timestamp):
                        regular_dict.popitem(False)
                        regular_dict[i] = {}
                        # 打印间隔时间的速率
                        print_rate(i)

                    # FIFO，弹出最前面的数据，并初始化新数据
                    regular_dict.popitem(False)
                    regular_dict[timestamp] = {}
                    regular_dict[timestamp][key] = 1

                    tmp_timestamp = timestamp
    except IOError as err:
        logger.error('File error: ' + str(err))
        return 1

if __name__ == '__main__':
    main()
