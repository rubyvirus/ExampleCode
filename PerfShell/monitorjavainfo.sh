#!/bin/bash
# Author rubyvirus@163.com
# use
# ./monitorjavainfo.sh pid options(heap,dump,gc)

now_time=`date +%Y%m%d%H%M%S`
pid_time=${1}${now_time}
pid=${1}

dump_file_name="javadump${pid_time}"
dump_heap_name="javaheap${pid_time}"
jstat_gc_file_name="javagc${pid_time}"

# redEcho function
function redEcho() {
    [ -c /dev/stdout ] && {
        # if stdout is console, turn on color output.
        echo -ne "\033[1;31m"
        echo -n "$@"
        echo -e "\033[0m"
    } || echo "$@"
}

# stdt thread info
function printStackOfThread() {

    while read threadLine ; do
        pid=`echo ${threadLine} | awk '{print $1}'`
        threadId=`echo ${threadLine} | awk '{print $2}'`
        threadId0x=`printf %x ${threadId}`
        user=`echo ${threadLine} | awk '{print $3}'`
        pcpu=`echo ${threadLine} | awk '{print $5}'`

        jstackFile=/tmp/${uuid}_${pid}

        [ ! -f "${jstackFile}" ] && {
            jstack ${pid} > ${jstackFile} || {
                redEcho "Fail to jstack java process ${pid}!"
                rm ${jstackFile}
                continue
            }
        }

        redEcho "Busy(${pcpu}%) thread(${threadId}/0x${threadId0x}) stack of java process(${pid}) under user(${user}):"
        sed "/nid=0x${threadId0x} /,/^$/p" -n ${jstackFile}
    done
}

# print thread infomation
function PS() {
	ps -Leo pid,lwp,user,comm,pcpu --no-headers | {
    	[ -z "${pid}" ] &&
    	awk '$4=="java"{print $0}' ||
    	awk -v "pid=${pid}" '$1==pid,$4=="java"{print $0}'
	} | sort -k5 -r -n | head -n "${1}" | printStackOfThread
}


# main
if [[ $# == 0 ]]; then
	#statements
	redEcho "please input java pid."
	jps
	exit 1
fi

if [[ ! -n $2 ]]; then
	#statements
	redEcho "please input heap,dump,gc command."
	exit 1
else
	case $2 in
		heap )
			count=${count:-5}
			if [[ -n $3 ]]; then
				#statements
				PS $3
			else
				PS $count
			fi
			;;
		dump )
			jmap -F -dump:format=b,file=${dump_file_name}.bin ${pid}
			# Use caution
			#jhat $dump_file_name.bin
			;;
		gc )
			nohup jstat -gcutil ${pid} 2s >> ${jstat_gc_file_name}.txt &
			redEcho "please see about [ view ./${jstat_gc_file_name}.txt ] infomation."
			;;
		* )
			redEcho "please input heap count,dump,gc command."
			exit 1
			;;
	esac
fi
