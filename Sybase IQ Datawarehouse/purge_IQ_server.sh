#!/bin/sh

echo
echo "Running as .... `whoami`"
. /opt/sybase/IQ-15_4/IQ-15.4.sh

export LANG=en_US

#Changing directory...
echo "Changing directory to /opt/sybase/databases/"
echo
cd /opt/sybase/databases

#Stopping server for log purge, this is required!!!
echo "Stopping CPIQ Server Now..."
#/opt/sybase/databases/stop_cpiq1
echo $?
#sleep 12000

#Removing log file
echo
echo "Removing CPIQ Server Log File..."
#mv /opt/sybase/databases/cpiq1.iqmsg /opt/sybase/databases/cpiq1.iqmsg_`date "+%d_%H_%M"`
echo $?

#touch /opt/sybase/databases/cpiq1.iqmsg

#Starting CPIQ Server
echo "Starting CPIQ Server..."
/opt/sybase/databases/start_cpiq1
echo $?
sleep 15

