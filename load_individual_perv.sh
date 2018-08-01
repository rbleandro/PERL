#!/bin/bash

. /opt/sybase/SYBSsa9/bin/asa_config.sh

export LANG=en_US
export ODBCINI=/opt/sybase/SYBSsa9/.odbc.ini
export LD_ASSUME_KERNEL=2.4.7

cd /opt/sybase/cron_scripts/sql/

/opt/sybase/SYBSsa9/bin/dbisql -c "uid=dba;pwd=sql" -host 192.1.1.88 -port 2638 -nogui load_nam_perv.sql
