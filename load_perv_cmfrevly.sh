#!/bin/bash
# Open check_prod file to see if it production or standby server.

    echo "Running as .... `whoami`"
    . /opt/sybase/SYBSsa9/bin/asa_config.sh

    export ODBCINI=/opt/sybase/SYBSsa9/.odbc.ini

    cd /opt/sybase/cron_scripts/sql/

    /opt/sybase/SYBSsa9/bin/dbisql -c "dsn=AMER_ASA" -nogui load_perv_cmfrevly.sql

