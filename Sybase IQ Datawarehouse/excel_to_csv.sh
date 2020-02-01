#!/bin/bash

sheet="`ls /opt/sybase/bcp_data/operations -Art | tail -n 1`"

if [ -z "$sheet" ]; then
	echo "No file to import!"
else
	file="/opt/sybase/bcp_data/Book1.xlsx"
	if [ -f "$file" ]; then
		echo 'sybase' | sudo -S rm /opt/sybase/bcp_data/Book1.xlsx
	fi

	cd /opt/sybase/bcp_data/operations
	echo 'sybase' | sudo -S cp "`ls /opt/sybase/bcp_data/operations -Art | tail -n 1`" /opt/sybase/bcp_data/
	echo 'sybase' | sudo -S mv "/opt/sybase/bcp_data/`ls /opt/sybase/bcp_data -Art | tail -n 1`" /opt/sybase/bcp_data/Book1.xlsx
	echo 'sybase' | sudo -S perl /opt/sybase/cron_scripts/excel_to_csv.pl > /opt/sybase/bcp_data/eng_temp.csv
	echo 'sybase' | sudo -S perl /opt/sybase/cron_scripts/reload_eng_temp.pl > /opt/sybase/cron_scripts/cron_logs/reload_eng_temp.log
	#echo "${?}"
	if [ $? -eq 0 ]
	then
	  echo 'sybase' | sudo -S rm /opt/sybase/bcp_data/operations/*.xlsx
	fi
fi