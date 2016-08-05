#!/bin/bash
# Author rubyvirus@163.com

now_time=`date +%Y%m%d%H%M%S`
pid_time=${1}${now_time}

dump_file_name="java${pid_time}"
jstat_gc_file_name="javagc${pid_time}"
function jstat_gc {
	while [[ true ]]; do
		#statements
		jstat -gcutil $1 2s >> ${jstat_gc_file_name}.txt
	done
}

function jmap_histo {
	while [[ true ]]; do
		#statements
		jmap -histo:live $1 >> "javahistoinfo${pid_time}".txt
		sleep 2000
	done
}



if [[ $# == 0 ]]; then
	#statements
	echo "please input java pid."
	jps
	exit 1
fi


case $2 in
	heap )
		jmap -heap $1 >> "javaheapinfo${2}".txt
		;;
	dump )
		jmap -F -dump:format=b,file=$dump_file_name.bin $1
		# Use caution
		#jhat $dump_file_name.bin
		;;
	histo )
		jmap_histo
		;;
	jstat )
		jstat_gc
		;;
	* )
		echo "please input heap,dump,histo,jstat command."
		exit 1
		;;
esac