#!/bin/bash

echo "Starting phone_stats...`date`"
echo
echo "Running as .... `whoami`"
. /opt/sybase/SYBSsa9/bin/asa_config.sh

export LANG=en_US
export ODBCINI=/opt/sybase/SYBSsa9/.odbc.ini
export LD_ASSUME_KERNEL=2.4.7

cd /opt/sybase/cron_scripts/sql/

/opt/sybase/SYBSsa9/bin/dbisql -c "dsn=AMER_ASA" -nogui load_test_perv.sql

echo
echo "Download from pervasive complete at...`date`"
echo
###########Truncate table and re-populate it
echo
echo "Truncating and uploading new data to sybase..."
echo

. /opt/sybase/SYBASE.sh

isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDATA2 <<EOF 2>&1
#/opt/sybase/OCS-12_5/bin/isql -Usa -w200 -SCPDATA2 -Psybase <<EOF
use cmf_data
go   
truncate table phone_stats
go
exit
EOF

/opt/sybase/OCS-12_5/bin/bcp cmf_data..phone_stats in /opt/sybase/cmf_data/asa/phone_stats.txt -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDATA2 -f/opt/sybase/bcp_data/cmf_data/phone_stats.fmt -Q


#/opt/sybase/OCS-12_5/bin/bcp cmf_data..phone_stats in /opt/sybase/cmf_data/asa/phone_stats.txt -Usa -Psybase -SCPDATA2 -f/opt/sybase/bcp_data/cmf_data/phone_stats.fmt -Q

echo
echo "Upload completed at...`date`"
echo

/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: Phone stats upload is done!

Go fish `date`
EOF

