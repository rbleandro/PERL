#!/usr/bin/perl -w

##############################################################################
#                                                                            #
#Author:    Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Apr 28 2008	Amer Khan 	Originally created                           #
#                                                                            #
##############################################################################

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

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "mpr_route_proc StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$currTime = localtime();
print "\nAll flags are set running proc now $currTime\n\n";
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use mpr_data
go
set replication off
go
execute mpr_route_proc
go
exit
EOF
`;
print $sqlError."\n";

$currTime = localtime();

if($sqlError =~ /no|not|Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - updating mpr_route_proc

Following status was received during mpr_route_proc that started on $currTime
$sqlError
EOF
`;

die "Cant continue, there were errors in this mpr_route_proc at $currTime \n";
}

#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$standbyserver -b -n<<EOF 2>&1
#use mpr_data
#go
#execute mpr_route_proc
#go
#exit
#EOF
#`;
#print $sqlError."\n";
#
#$currTime = localtime();
#
#if($sqlError =~ /no|not|Msg/){
#      print "Errors may have occurred during update...\n\n";
#`/usr/sbin/sendmail -t -i <<EOF
#To: CANPARDatabaseAdministratorsStaffList\@canpar.com
#Subject: ERROR - updating mpr_route_proc -- IN STDBY SERVER
#
#Following status was received during mpr_route_proc that started on $currTime
#$sqlError
#EOF
#`;
#
#die "Cant continue, there were errors in this mpr_route_proc at $currTime \n";
#}
#
#$currTime = localtime();
#print "mpr_route_proc FinTime: $currTime\n";
#
`touch /tmp/mpr_route_proc_done`;

