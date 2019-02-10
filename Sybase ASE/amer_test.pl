#!/usr/bin/perl -w

##############################################################################
#Script:   This script updates lh_actual in linehaul_data                    #
#                                                                            #
#Author:   Amer Arain                                                        #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#2014/06/3     Amer Arain       Originally created                           #
#                                                                            #
#2014/06/3      Amer Arain      Modified
###################################################################################

#Usage Restrictions
$prodserver = "CPSYBTEST";
#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = ""; # Initialize Var

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -Ps9b2s3 -S$prodserver -b -n<<EOF 2>&1
use lmscan
go
execute AmerA_Test
go
exit
EOF
`;
print $sqlError."\n";

if($sqlError =~ /no\s|not/ || $sqlError =~ /error/i){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: aarain\@canpar.com
Subject:   $prodserver ERROR - Testing AmerA_Test Proc to linehaul_data

Followinv status was received during update in lmscan..AmerA_Test that started on $currTime
$sqlError
EOF
`;
}
$currTime = localtime();
print "FinTime on $standbyserver: $currTime\n";
