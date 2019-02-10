#!/bin/bash

# Open check_prod file to see if it production or standby server.
 
exec 6</opt/sap/cron_scripts/passwords/check_prod
standbyserver="PROD	0"

# Read the record from check_prod file
while read -u 6 dta
do
    server=$dta
done

echo "$server"
echo $standbyserver

if  [ "$server" =  "$standbyserver" ]   
then
    echo "Standby Server... So I am going to die!!!"

else 

    echo
    echo "Running as .... `whoami`"
    . /opt/sap/SYBSsa9/bin/asa_config.sh

    export LANG=en_US
    export ODBCINI=/opt/sap/SYBSsa9/.odbc.ini
	
    mv /opt/sap/cron_scripts/cron_logs/load_cmf_data.log /opt/sap/cron_scripts/cron_logs/load_cmf_data.bk

    cd /opt/sap/cron_scripts/sql/

    /opt/sap/SYBSsa9/bin/dbisql -c "dsn=AMER_ASA" -nogui load_perv.sql

    echo "Running cmf data load now...`date`"
    echo
#    mv /opt/sap/cron_scripts/cron_logs/load_cmf_data.log /opt/sap/cron_scripts/cron_logs/load_cmf_data.bk
    /opt/sap/cron_scripts/load_cmf_data.pl  > /opt/sap/cron_scripts/cron_logs/load_cmf_data.log 2>&1
fi
