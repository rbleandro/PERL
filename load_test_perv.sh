#!/bin/bash

echo
echo "Running as .... `whoami`"
. /opt/sybase/SYBSsa9/bin/asa_config.sh

export LANG=en_US
export ODBCINI=/opt/sybase/SYBSsa9/.odbc.ini
export LD_ASSUME_KERNEL=2.4.7

cd /opt/sybase/cron_scripts/sql/

/opt/sybase/SYBSsa9/bin/dbisql -c "dsn=AMER_ASA" -nogui load_test_perv.sql
