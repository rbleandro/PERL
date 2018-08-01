#!/usr/bin/perl -w

##############################################################################
#Script:   This script loads data into vp_alltotals_terminal of              #
#	   mpr_data from etime for monthly terminal info                     #
#	   This script depends on an schedule task in etime server, which    #
#	   runs on the 10th of every month. So this script should on the 11th#
#	   or after every month. This sets data for fiscal month.	     #
#                                                                            #
#Author:   Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
# Jan 23, 2011	Amer Khan						     #
#----------------------------------------------------------------------------#
#                                                                            #
##############################################################################

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

#the following line is for testing purposes only and should be commented out when test
# and development is complete
#####################

#Setting Sybase environment is set properly

require "/opt/sap/cron_scripts/set_sybase_env.pl";


#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";


$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use mpr_data
go
truncate table vp_alltotals_terminal 
go
exit
EOF
bcp mpr_data..vp_alltotals_terminal in /opt/sap/bcp_data/mpr_data/vp_terminal/vp_alltotals_terminal.dat -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\r\n"
`;
print $sqlError."\n";

$currTime = localtime();

if($sqlError =~ /failed/){
      print "Errors may have occurred during bcp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - bcp vp_alltotals_terminal

Following status was received during bcp in of vp_alltotals_terminal that started on $currTime
$sqlError
EOF
`;
}else{ #All is well, so proceed to processing data into secondary tables....

# Process data from vp_alltotals_terminal into secondary tables...
$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use mpr_data
go
execute vp_alltotals_terminal_feed    
go    
exit    
EOF   
`;
}
print "$sqlError\n";

$currTime = localtime();
if($sqlError =~ /failed/){
      print "Errors may have occurred during bcp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com 
Subject: ERROR - vp_alltotals_terminal_feed

Following status was received during execution of vp_alltotals_terminal_feed that started on $currTime
$sqlError
EOF
`;
}else
{ `touch /tmp/emp_terminal_time_load_done`;
#  `rm /opt/sap/bcp_data/mpr_data/vp_terminal/vp_alltotals_terminal.dat`;
}
