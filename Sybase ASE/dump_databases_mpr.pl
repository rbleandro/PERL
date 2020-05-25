#!/usr/bin/perl -w

##########################################################################################################################################################
#Script:   This script checks SVP URL delays
#
#Author:	Amer Khan
#Revision:
#Date           Name            Description
#----------------------------------------------------------------------------
#Oct  12 2016	Amer Khan		Created
#July 01 2018	Rafael Leandro	Added logic to copy and load the databases on DR (CPDB4)
#Aug  01 2019	Rafael Leandro	Added logic to dynamically setup the backup folder since they are not consistent accross the servers.
###########################################################################################################################################################

#Usage Restrictions
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();
$drserver = 'CPDB4';

if (hostname() eq 'CPDB4') {
	print "DR server \n";
    die "This is the DR server. No additional logic will be processed until the primary servers are back online.\n"
}

if ($prodserver eq 'CPDB2'){ $stbyserver = 'CPDB1'; $lbkpdir='/opt/sap'; $rbkpdir='/opt/sap';} else { $stbyserver = 'CPDB2'; $lbkpdir='/opt/sap'; $rbkpdir='/opt/sap';}

print "Prod: $prodserver....Stby: $stbyserver \n";

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep dump_databases.pl|grep -v grep|grep -v $my_pid|grep -v "vim dump_databases.pl"|grep -v "less dump_databases.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";


$sqlError = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver <<EOF 2>&1
use master
go
dump database mpr_data to "$lbkpdir/db_backups/mpr_data.dmp" compression=100
go
dump database mpr_data_lm to "$lbkpdir/db_backups/mpr_data_lm.dmp" compression=100
go
exit
EOF
`;
if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Errors - dump_databases at $finTime

$sqlError
EOF
`;
die;
}

#Copying files to standby server
$scpError=`scp -p $lbkpdir/db_backups/mpr_data.dmp sybase\@$stbyserver:$rbkpdir/db_backups`;
print "$scpError\n";

$scpError=`scp -p $lbkpdir/db_backups/mpr_data_lm.dmp sybase\@$stbyserver:$rbkpdir/db_backups`;
print "$scpError\n";


#Copying files to DR server
$scpError=`scp -p $lbkpdir/db_backups/mpr_data.dmp sybase\@$drserver:$lbkpdir/db_backups`;
print "$scpError\n";

$scpError=`scp -p $lbkpdir/db_backups/mpr_data_lm.dmp sybase\@$drserver:$lbkpdir/db_backups`;
print "$scpError\n";


###############################
#Run load in standby server now
###############################

#Loading databases into standby server
$load_msgs = `ssh $stbyserver /opt/sap/cron_scripts/load_databases_mpr.pl -s $stbyserver`;
#Loading databases into DR server
$load_msgs_dr = `ssh $drserver /opt/sap/cron_scripts/load_databases_mpr.pl -s $drserver`;

print "$load_msgs \n";
print "$load_msgs_dr \n";

$finTime = localtime();
print "Time Finished: $finTime\n";
