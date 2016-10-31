ALLOW_IP_PATH='/etc/foreign_login/allow_ip.conf'
ALLOW_AREA_PATH='/etc/foreign_login/allow_area.conf'
LOG_FILE="/tmp/${USER}_foreign_login.log"

. stderr.sh

#######################################
# Check login type
# Globals: (Read Only)
#   SSH_CLIENT
#   SSH_CONNECTION
#   ALLOW_IP_PATH
#   ALLOW_AREA_PATH
#   LOG_FILE
# Arguments:
#   None
# Returns:
#   0 Normal
#   1 Error
#######################################
check_login(){
    # 本地登陆则放行
    if [ -z "$SSH_CLIENT" ]; then
        return 0
    fi  

    # git判断ssh端口非222端口则放行
	PORT=$(echo "$SSH_CLIENT" |awk '{print $NF}')
    if [[ "$PORT" -ne "222" ]]; then
        return 0
    fi

    # 局域网登陆放行
    if echo "$SSH_CLIENT" |grep -q '^192\.168\.'; then
        return 0
    fi

    # 放行白名单IP
    # TODO(csr): 支持网段IP (ticket 0.1)
	IP=$(echo "$SSH_CLIENT" |cut -d ' ' -f1)
	# for i in $(cat $ALLOW_IP_PATH 2>/dev/null); do
	< $ALLOW_IP_PATH | while IFS= read -r i; do
        if [ "$IP" == "$i" ]; then
            return 0
        fi  
    done	

    # 放行白名单区域，需要联网判断，并记录错误日志

    # 网络不通直接放行，不通的时候用域名会超时20s+
    #   并会出现这个错误：Could not resolve host
    if ! ping -c 1 -W 1 114.114.114.114 >/dev/null 2>&1; then
        log "$SSH_CONNECTION: ping loss" >>"$LOG_FILE"
        return 0
    fi

	area=$(curl "cip.cc/$IP" 2>/dev/null)
    # curl不到内容或者curl出来的结果不正确的也直接放行，避免误封
    if [ -z "$area" ]; then
        log "$SSH_CONNECTION: curl nothing" >>"$LOG_FILE"
        return 0
    fi  
    if ! echo "$area" |grep -q "$IP"; then
        log "$SSH_CONNECTION: curl content error" >>"$LOG_FILE"
        return 0
    fi  

	# for i in $(cat $ALLOW_AREA_PATH 2>/dev/null); do
	< $ALLOW_AREA_PATH | while IFS= read -r i; do
        # 前面已经判断过192.168.0.0/32的局域网网段了，但是还是要判断其他局域网网段
        if echo "$area" |grep -Pq "$i|内网|局域网"; then
            return 0
        fi  
    done

    log "Foreign IP: $SSH_CONNECTION" >>"$LOG_FILE"
    return 1
}

check_login

unset -f check_login
unset -f log
unset -f err
unset ALLOW_IP_PATH
unset ALLOW_AREA_PATH
unset LOG_FILE
