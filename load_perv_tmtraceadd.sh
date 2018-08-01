#!/bin/bash
# Open check_prod file to see if it production or standby server.

exec 6</opt/sybase/cron_scripts/passwords/check_prod
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
    . /opt/sybase/SYBSsa9/bin/asa_config.sh

    export LANG=en_US
    export ODBCINI=/opt/sybase/SYBSsa9/.odbc.ini
    export LD_ASSUME_KERNEL=2.4.7

    cd /opt/sybase/cron_scripts/sql/

    /opt/sybase/SYBSsa9/bin/dbisql -c "dsn=AMER_ASA" -nogui load_perv_tmtraceadd.sql 

fi
