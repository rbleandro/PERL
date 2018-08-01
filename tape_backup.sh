#!/bin/sh
# full and incremental backup script
# created 07 February 2000
# Based on a script by Daniel O'Callaghan <danny@freebsd.org>
# and modified by Gerhard Mourani <gmourani@videotron.ca>
# modified for tape use by Chad Amberg <http://www.bluestream.org>

#Change the 3 variables below to fit your computer/backup

#DIRECTORIES="/etc /home /opt /root /var"  # directories to backup
DIRECTORIES="/opt/sybase/db_backups/stripe11/cpscan.dmp1 /opt/sybase/db_backups/stripe12/cpscan.dmp2 /opt/sybase/db_backups/stripe13/cpscan.dmp3 /opt/sybase/db_backups/stripe14/cpscan.dmp4"
BACKUPTO=/dev/nst0                         # where to store the backups
TAR=/bin/tar                              # name and locaction of tar

#You should not have to change anything below here

PATH=/usr/local/bin:/usr/bin:/bin
START=`date +%s`

# Daily full backup
        NEWER=""
        echo "***** start time"
        date
        echo
        if mt -f /$BACKUPTO status | grep "ONLINE"; then
                echo "***** finding sockets"
                find $DIRECTORIES -type s > sockets
                echo
                echo "***** setting compression on"
                mt -f /$BACKUPTO compression 1
                echo
                echo "***** archiving"
                $TAR $NEWER -cf $BACKUPTO $DIRECTORIES --exclude-from=sockets --absolute-names --totals  # --exclude-from=tbackup.ignore
                echo
                echo "***** tape-drive status"
                mt -f /$BACKUPTO status
                echo
                echo "***** ejecting tape"
                mt -f /$BACKUPTO offline
                echo
                echo "***** end time"
                date
        else
                echo "***** WARNING TAPE DRIVE IS OFFLINE, NO BACKUPS PERFORMED"
        fi
FINISH=`date +%s`
diff=$((FINISH - START))
echo -n "***** Total Run Time: "
HRS=`expr $diff / 3600`
MIN=`expr $diff % 3600 / 60`
SEC=`expr $diff % 3600 % 60`
if [ $HRS -gt 0 ]
then
 echo -n "$HRS hrs. "
fi
if [ $MIN -gt 0 ]
then
 echo -n "$MIN mins. "
fi
if [ $SEC -gt 0 ]
then
 if [ $MIN -gt 0 ]
 then
  echo "and $SEC secs."
 elif [ $HRS -gt 0 ]
 then
  echo "and $SEC secs."
 else
  echo "$SEC secs."
 fi
fi
