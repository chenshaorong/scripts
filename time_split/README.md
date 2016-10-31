## 功能：分割指定时间段的日志

## perl vs sed

```
$ time perl -ne 'if(/01:00:00/){$flag=1;} if($flag == 1){print; exit(0) if /01:00:03/}' oschina.log |wc -l
107

real	0m0.132s
user	0m0.128s
sys	0m0.000s
$ time perl -ne 'if($flag != 1 && /01:00:00/){$flag=1;} if($flag == 1){print; exit(0) if /01:00:03/}' oschina.log |wc -l
107

real	0m0.123s
user	0m0.108s
sys	0m0.012s
$ time sed -n '/01:00:00/,/01:00:03/'p oschina.log |wc -l
107

real	0m2.415s
user	0m2.296s
sys	0m0.120s
$ time ./time_split.sh -f oschina.log -s 1:00 -e 1:00:03 |wc -l
106  # 这个才是正确的，前几个会多出一条01:00:03的

real	0m0.348s
user	0m0.284s
sys	0m0.008s
```
