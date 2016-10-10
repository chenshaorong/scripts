#!/bin/bash
# Author: csr 
# Date：2016-10-09
# Email: 731685435@qq.com
# Version: v1.0

. stderr.sh

f_trap() {
	err "trap $1"
}

# trap sign/ERR/EXIT, man bash, then search '/^ +trap'
# trap "f_trap $LINENO" ERR EXIT	# $LINENO=14
# trap 'f_trap "$LINENO"' ERR EXIT	# $LINENO=21
trap 'f_trap "ERR $LINENO"' ERR
trap 'f_trap "EXIT $LINENO"' EXIT

# $ ./$0 cst	# trap ERR and EXIT
# $ ./$0 csr	# trap EXIT
echo "$1" |grep -q csr
