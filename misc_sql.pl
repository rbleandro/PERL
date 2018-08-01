#!/usr/bin/perl -w

##############################################################################
#                                                                            #
#Author:    Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Feb 13 2012	Amer Khan 	Originally created                           #
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

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "Misc Job StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$currTime = localtime();
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use mpr_data
go
execute mpr_hub_costs_load_proc 'Nov 28 2015','Dec 25 2015'
go    
execute mpr_preload_costs_load_proc 'Nov 28 2015','Dec 25 2015'
go
fiscal_shipment_data_update 12
go
exit
EOF
`;
print $sqlError."\n";

$currTime = localtime();

print "Misc FinTime: $currTime\n";

