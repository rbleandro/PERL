#!/bin/bash
. /opt/sap/SYBASE.sh
echo "I'm sleeping for 12 seconds to avoid renewing the ticket while ASE connections are being estabilished"
echo "crontab scheduling does not allow second specification that's why I'm doing this here"
sleep 12 
/krb5/bin/64/kinit -k sybase@CANPAR.COM
echo "Ticket for user sybase renewed"
