#!/bin/bash
# Author: csr 
# Date：2016-10-09
# Email: 731685435@qq.com
# Version: v1.0

#######################################
# print err message
# Globals: (Read Only)
#   USER
#   BASH_LINENO[index]
#   FUNCNAME[index]
#   BASH_SOURCE[index]
# Arguments:
#   *
# Returns:
#   None
# Output Format:
#   user [time] "file1 fun1 line1" => \
#     "file2 fun2 line2" => ...: err message
#######################################
err() {
	# ${BASH_LINENO[*|@]} $*|$@, use $*: This concatenates based on IFS.
	# $0, $LINENO, main(): 0
	echo -ne "\033[36m$USER [$(date +'%Y-%m-%dT%H:%M:%S %z')] " >&2
	local num=${#BASH_LINENO[*]}
	for i in $(seq 3 $num); do
		echo -n " \"${BASH_SOURCE[$num-$i+2]}: ${BASH_LINENO[$num-$i+1]} ${FUNCNAME[$num-$i+1]}()\" =>" >&2
	done
	echo -n " \"${BASH_SOURCE[1]}: ${BASH_LINENO[0]} ${FUNCNAME[0]}()\"" >&2
	echo -e ":\033[0m\033[31m $*\033[0m" >&2
}

#######################################
# print log message
# Globals: (Read Only)
#   USER
#   BASH_LINENO[index]
#   FUNCNAME[index]
#   BASH_SOURCE[index]
# Arguments:
#   *
# Returns:
#   None
# Output Format:
#   user [time] "file1 fun1 line1" => \
#     "file2 fun2 line2" => ...: err message
#######################################
log() {
	# ${BASH_LINENO[*|@]} $*|$@, use $*: This concatenates based on IFS.
	# $0, $LINENO, main(): 0
	echo -ne "$USER [$(date +'%Y-%m-%dT%H:%M:%S %z')] " >&2
	local num=${#BASH_LINENO[*]}
	for i in $(seq 3 $num); do
		echo -n " \"${BASH_SOURCE[$num-$i+2]}: ${BASH_LINENO[$num-$i+1]} ${FUNCNAME[$num-$i+1]}()\" =>" >&2
	done
	echo " \"${BASH_SOURCE[1]}: ${BASH_LINENO[0]} ${FUNCNAME[0]}()\": $*" >&2
}
