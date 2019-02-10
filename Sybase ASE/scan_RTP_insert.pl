#!/usr/bin/perl -w

##############################################################################
#Script:   This script process scan_RTP_insert from Monday to Friday                    #
#                                                                            #
#                                                                            #
#Author:   Ahsan Ahmed
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#                                                                            #
#01/14/2011      Ahsan Ahmed      Created
###################################################################################

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

#Setting Sybase environment is set properly

require "/opt/sap/cron_scripts/set_sybase_env.pl";


#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Execute  scan_RTP_insert

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data    
go   
execute scan_RTP_insert   
go    
exit
EOF
`;
print $sqlError."\n";

 if ($sqlError =~ /Error/i || $sqlError =~ /no/i || $sqlError =~ /message/i){
      print "Messages From scan_RTP...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,kkotur\@canpar.com
Subject: scan_RTP errors -- RTP will not be processed!!

$sqlError
EOF
`;
}else{
#Convert files to xls now...
`/opt/sap/cron_scripts/process_scan_RTP.pl`;
}
