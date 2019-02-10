#!/usr/bin/perl -w

###################################################################################
#Script:   This script updates tttl_ev_event data for multiple_barcodes           #
#          on regular scheduled basis                                             #
#                                                                                 #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#July 18,2005	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";

print "***Initiating tttl_ev mb_update At:".localtime()."***\n";
open(STDERR,"> /tmp/upd.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/SYBASE.sh
. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'CALL "DBA"."tttl_ev_mb_changes"()'`;

close(STDERR);

open(ERRFILE,"< /tmp/upd.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/upd.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From mb updates...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: mupltiple_barcodes updates

$dbsqlError
EOF
`;
}else{
   print $dbsqlError;
}
