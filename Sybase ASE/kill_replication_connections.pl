#!/usr/bin/perl -w

###################################################################################
#Script:   This script drops replication connections for certain databases in     #
#          anticipation that there will be very high activity over the weekend    #
#          which can be better handled by resyncing the dbs as opposed to         #
#          direct replication.                                                    #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#Oct 11 2013	Amer Khan	Originally created                                #
###################################################################################

#Usage Restrictions
open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
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
if ($prodserver eq "CPDB2" ) {
    $standbyserver = "CPDB1";
}
else
{
   $standbyserver = "CPDB2";
}
if ($#ARGV eq "0"){
    $database = $ARGV[0];
    $dumptype = "dumpload";
}
if ($#ARGV eq "1"){
    $database = $ARGV[0];
    $dumptype = $ARGV[1];
}

#Usage Restrictions
if ($#ARGV > 1){
   print "Usage: dumpdb.pl cpscan optional (dumponly) \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

print "\n***********************************\ndatabase: $database dumptype: $dumptype standbyserver: $standbyserver prod: $prodserver \n***********************\n";


#Store inputs
$database = $ARGV[0];

#Set starting variables
$currTime = localtime();
$startDay=sprintf('%02d',((localtime())[6]));
$startHour=sprintf('%02d',((localtime())[2]));
$startMin=sprintf('%02d',((localtime())[1]));

use POSIX qw(strftime);
$currDay = lc(strftime "%A", localtime);

#***************Suspending replication and preparing to resync************
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Shqvsybrep1 -w300 <<EOF 2>&1
suspend connection to $standbyserver.cpscan
go
drop connection to $standbyserver.cpscan
go
suspend connection to $standbyserver.mpr_data
go
drop connection to $standbyserver.mpr_data
go
`;

print "\n".localtime().":********replication messages*********\n\n$sqlError\n";


if($sqlError =~ /Failed/i || $sqlError =~ /error/i){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - Kill Replication Connections Failed

Following messages were received after ssh load attempt
$sshError
EOF
`;
}

