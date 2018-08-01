#!/bin/bash

su - sybase
echo "I am running as ...`whoami`"
echo
cp /opt/sybase/ASE-12_5/install/CPDATA1.log /opt/sybase/ASE-12_5/install/CPDATA1_last_night_FULL.log
egrep -v 'extended error|Connection timed out|host process disconnected|Error: 1608|A client process exited abnormally' /opt/sybase/ASE-12_5/install/CPDATA1.log > /opt/sybase/ASE-12_5/install/CPDATA1_last_night.log

cat /dev/null > /opt/sybase/ASE-12_5/install/CPDATA1.log

echo
echo "Purged Server Log At `date`"
echo

