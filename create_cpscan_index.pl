#!/usr/bin/perl -w

##############################################################################
#Script:   This script creates a new index in cpscan                         #
#                                                                            #
#Author:   Ahsan Ahmed							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#2006/12/11	Ahsan Ahmed	Originally created                           #
#                                                                            #
#11/01/07      Ahsan Ahmed      Modified                                     #
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


#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = ""; # Initialize Var

$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use cpscan
go     
set replication off
go         
CREATE NONCLUSTERED INDEX ship_scandt
    ON dbo.tttl_ev_event(shipper_num,scan_time_date)
go      
set replication on
go
exit        
EOF
`;
print $sqlError."\n";

if($sqlError =~ /no\s|not/ || $sqlError =~ /error/i){
      print "Errors may have occurred during index creation...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com 
Subject:   $prodserver ERROR - cpscan index creation

Following status was received during creation of cpscan index that started on $currTime
$sqlError
EOF
`;
}
