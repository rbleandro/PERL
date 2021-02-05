#!/bin/bash

#if the operations folder is not mounted, use the command below to do so
#sudo mount "//10.3.1.186/Department/Information Technology/DevDump/operations" /opt/sybase/bcp_data/operations -o username=em_process1,password=Canpar_2001,domain=canparnt

#echo "Test Mount Point...\n";
#mount_pt="`cat /etc/mtab | grep "operations "`"
#if [ -z "$mount_pt" ]; then
   echo 'B4rIQC9e' | sudo mount "//10.3.1.186/Department/Information Technology/DevDump/operations" /opt/sybase/bcp_data/operations -o username=em_process1,password=Canpar_2001,domain=canparnt 
#   else
#   echo "Dir is already mounted \n";
#fi

sheet="`ls /opt/sybase/bcp_data/operations -Art | tail -n 1`"

if [ -z "$sheet" ]; then
	echo "No file to import!"
else
	file="/opt/sybase/bcp_data/Book1.xlsx"
	if [ -f "$file" ]; then
		echo 'B4rIQC9e' | sudo -S rm /opt/sybase/bcp_data/Book1.xlsx
	fi

	cd /opt/sybase/bcp_data/operations
	echo 'B4rIQC9e' | sudo -S cp "`ls /opt/sybase/bcp_data/operations -Art | tail -n 1`" /opt/sybase/bcp_data/
	echo 'B4rIQC9e' | sudo -S mv "/opt/sybase/bcp_data/`ls /opt/sybase/bcp_data -Art | tail -n 1`" /opt/sybase/bcp_data/Book1.xlsx
	echo 'B4rIQC9e' | sudo -S perl /opt/sybase/cron_scripts/excel_to_csv.pl > /opt/sybase/bcp_data/eng_temp.csv
	echo 'B4rIQC9e' | sudo -S perl /opt/sybase/cron_scripts/reload_eng_temp.pl > /opt/sybase/cron_scripts/cron_logs/reload_eng_temp.log
	#echo "${?}"
	if [ $? -eq 0 ]
	then
	  echo 'B4rIQC9e' | sudo -S rm /opt/sybase/bcp_data/operations/*.xlsx
	fi
fi