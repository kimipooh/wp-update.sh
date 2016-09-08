#!/bin/sh

# System Environments
base_dir="/home/◯◯/bin/"
target_db_file="${base_dir}/wp-targets.dat"

WP_CLI="/usr/local/bin/wp"
backup_base_dir="/home/××/backup/"
logs="$backup_base_dir/logs"
log_file="$logs/`date +%Y%m%d`.log"

if [ ! -f "$WP_CLI" ]; then
 echo "Cannot run $WP_CLI"
 exit
fi

if [ ! -f "$target_db_file" ]; then
 echo "Please set up the environment file."
 echo '[backup folder name]:[backwpup job ID]:[WordPress folder]'
 exit
fi

target_db_list=`grep -v '#' $target_db_file`

# Loop
for target_db in $target_db_list; do

# Format check
SEP_CHECK=`echo $target_db | awk '{num=split($0,arr,":"); print num;}'`
if [ "$SEP_CHECK" != 4 ]; then
 echo "Format Error."
 echo '[backup folder name]:[backwpup job ID]:[WordPress folder]'
 exit
fi

# GET Folder and JobID
wp_name=`echo $target_db | awk -F':' '{print $1}'`
wp_jobid=`echo $target_db | awk -F':' '{print $2}'`
wp_default_lang=`echo $target_db | awk -F':' '{print $3}'`
wp_dir=`echo $target_db | awk -F':' '{print $4}'`

if [ -d "$wp_dir" ]; then
  if [ -d "$backup_base_dir/$wp_name" ]; then
{
    echo "$wp_name : ### Backup WordPress files/folder and Database using BackWPUP Plugin ###"
    echo "$wp_dir"

    cd $wp_dir
    $WP_CLI backwpup start --jobid=$wp_jobid
    $WP_CLI plugin list | grep available | cut -d '|' -f 2 | awk  '{print "/usr/local/bin/wp plugin update "$1}' |sh
    if [ "$wp_default_lang" = "en" ]; then
      $WP_CLI core update && $WP_CLI core update-db
    else
      $WP_CLI core update --force --locale=$wp_default_lang && $WP_CLI core update-db
    fi
    $WP_CLI plugin list | grep available | cut -d '|' -f 2 | awk  '{print "/usr/local/bin/wp plugin update "$1}' |sh

    echo ""
    echo "##End of LOG###"
    echo ""
} 1> $log_file 2>&1
  fi
fi

done
