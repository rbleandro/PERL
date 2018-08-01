#!/usr/bin/perl -w

##############################################################################
#Script:   This script  deleted staging iq_tables every night                #
#                                                                            #
#                                                                            #
#Author:   Ahsan Ahmned                                                      #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Dec 4th 2012	Ahsan Ahmed	Originally Created                           #
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
}else{
   $standbyserver = "CPDB2";
}

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$standbyserver <<EOF 2>&1
use iq_stage
go
exec truncate_iq_stage_tables   
go   
exit
EOF
`;

print "Any message from the proc execution...\n $sqlError \n";

if ($sqlError =~ /Msg/ || $sqlError =~ /no|not/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To:CANPARDatabaseAdministratorsStaffList\@canpar.com 
Subject:  deleted staging iq_tables at $finTime

$sqlError
EOF
`;
}
