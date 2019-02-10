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
    /usr/bin/crontab -l > /opt/sap/cron_scripts/cronjobs.bk

print "Spitting cron entries here as well as secondary backup"
/usr/bin/crontab -l
fi
