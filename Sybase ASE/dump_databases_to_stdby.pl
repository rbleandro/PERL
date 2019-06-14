#!/usr/bin/perl -w

#####################################################################################
#Script:   This script dumps a database and copies the dump file to standby server  #
#                                                                            		#
#Author:	Rafael Bahia												     		#
#Revision:                                                                   		#
#Date           Name            Description                                  		#
#-----------------------------------------------------------------------------------#
#Jan 7 2019		Rafael Bahia	Created					 				     		#
#####################################################################################

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

if ($prodserver eq 'CPDB2'){ $stbyserver = 'CPDB1'; } else { $stbyserver = 'CPDB2'; }

print "Prod: $prodserver....Stby: $stbyserver \n";

$database = $ARGV[0];

my $dba = $ARGV[1];
if (defined $dba) {
    $mail=$dba;
} else {
    $mail='CANPARDatabaseAdministratorsStaffList';
} 

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep dump_databases_to_stdby.pl|grep -v grep|grep -v $my_pid|grep -v "vim dump_databases_to_stdby.pl"|grep -v "less dump_databases_to_stdby.pl"`;

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
dump database $database to "/home/sybase/db_backups/$database.dmp" compression=100
go
exit
EOF
`;
if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases_to_stdby at $finTime

$sqlError
EOF
`;
die;
}

#Copying files to standby server
$scpError=`scp -p /home/sybase/db_backups/$database.dmp sybase\@$stbyserver:/opt/sap/db_backups`;
print "$scpError\n";

$scpError  = $? >> 8;
if ($scpError != 0) {
print "$scpError\n";
$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases_to_test (scp phase) at $finTime

$scpError
EOF
`;
die;
}

###############################
#Run load in standby server now
###############################

#Loading databases into standby server
$load_msgs = `ssh $stbyserver /opt/sap/cron_scripts/load_databases_to_stdby.pl $database $mail`;
#Loading databases into DR server
#$load_msgs_dr = `ssh $drserver /opt/sap/cron_scripts/load_databases_mpr.pl $drserver`;

print "$load_msgs \n";
#print "$load_msgs_dr \n";

$finTime = localtime();
print "Time Finished: $finTime\n";
