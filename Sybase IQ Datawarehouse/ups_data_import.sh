#!/bin/bash

#echo 'B4rIQC9e' | sudo mount "//10.3.1.186/appvol/AppData/UPS" /opt/sybase/bcp_data/ups_import -o username=em_process1,password=Canpar_2001,domain=canparnt
sheet="`ls /opt/sybase/bcp_data/ups_import -Art | tail -n 1`"
sheetpath="`ls /opt/sybase/bcp_data/ups_import/*.csv -Art | tail -n 1`"

echo $sheet
echo $sheetpath

if [ -z "$sheet" ]; then
	echo "No file to import!"
else
	cd /opt/sybase/bcp_data
	echo 'B4rIQC9e' | sudo -S cp $sheetpath /opt/sybase/bcp_data/
	
	if [ $? -eq 0 ]; then
		echo "File copied from the shared folder. Proceeding..."
	else
		echo "Could not copy file from the shared folder. Verify that the folder is mounted properly. Exiting."
		exit
	fi
	
	echo 'B4rIQC9e' | sudo -S mv $sheet /opt/sybase/bcp_data/ups_shipment_load.csv
	if [ $? -eq 0 ]; then
		echo "File renamed successfully. Proceeding..."
	else
		echo "Could not rename file. Verify that you have the correct permissions. Exiting."
		exit
	fi
	
	echo 'B4rIQC9e' | sudo -S perl /opt/sybase/cron_scripts/ups_data_import.pl > /opt/sybase/bcp_data/ups_shipment.csv
	echo 'B4rIQC9e' | sudo -S perl /opt/sybase/cron_scripts/reload_ups_shipment.pl > /opt/sybase/cron_scripts/cron_logs/reload_ups_shipment.log
	#echo "${?}"
	
	#if [ $? -eq 0 ]
	#then
	#	echo 'B4rIQC9e' | sudo -S rm $sheetpath
	#	
	#	if [ $? -eq 0 ]; then
	#		echo "File removed successfully from the shared folder."
	#	else
	#		echo "Could not remove the file successfully from the shared folder. Verify that it is not locked by another user or that it still exists. Exiting."
	#		exit
	#	fi
	#fi
fi