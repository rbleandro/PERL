#!/usr/bin/perl -w

###################################################################################
#Script:   This script refreshes data from ASE Prod rev_hist to IQ every night    #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#Mar 24,2010	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

print "\n###Running rev_hist load to cpiq on Host:".`hostname`." at ".localtime()."  ###\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute load_rev_hist_from_ase' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From Load rev_hist Data from ASE...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: Load rev_hist Data from ASE...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n***Load rev_hist Data from ASE...Aborting Now!!***\n\n";
}else{
print "Completed Successfully!! at ".localtime()."\n";
}

