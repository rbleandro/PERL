#!/bin/bash

echo
egrep -v 'nspacket: send, Connection reset by peer' /opt/sybase/ASE-15_0/install/CPDB1.log | egrep -v 'Cannot send, host process disconnected|Error: 1608|A client process exited abnormally|extended error' | egrep -v 'DBCC TRACEON 3604' | egrep -v 'Cannot read, host process disconnected:' | egrep -v 'DBCC TRACEOFF 3604' | egrep -v 'nrpacket: recv, Connection timed out' >> /opt/sybase/ASE-15_0/install/CPDB1_actual_errors.log

cat /dev/null > /opt/sybase/ASE-15_0/install/CPDB1.log

echo
echo "Purged Server Log At `date`"
echo

