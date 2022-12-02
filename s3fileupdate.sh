#!/usr/bin/bash

current_dir=$(pwd)
s3_head="s3://cytodata"
while read line
do 
	target_fl="$(echo ${line} | awk '{print $4}')"
	target_fs=$(echo ${line} | awk '{print $3}')
	fl_dir="$(dirname ${target_fl})"
	if [ ${target_fs} -eq 0 ]
	then 
		echo "Skip ${line}" >> update.log
		continue 
	fi

	if [ -f $current_dir/$target_fl ]
	then
		local_fs=$(wc -c $current_dir/$target_fl | awk '{print $1}')
		if [ $local_fs -eq $target_fs ]
		then 
			continue 
		else
			echo "Updating ${current_dir}/${target_fl}" >> update.log
			aws s3 cp --no-sign-request --only-show-errors $s3_head/$target_fl $current_dir/$target_fl
		fi
	else
		if [ ! -d $current_dir/$fl_dir ]
		then 
			mkdir -p $current_dir/$fl_dir
		fi
		echo "Downloading ${s3_head}/${target_fl}" >> update.log
		aws s3 cp --no-sign-request --only-show-errors $s3_head/$target_fl $current_dir/$target_fl
	fi
done < U2OS_files.dat
