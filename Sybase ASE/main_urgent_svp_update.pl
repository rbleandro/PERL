#!/usr/bin/perl 

##############################################################################
#Description: This script runs the proc parcelwork procedures                #
#                                                                            #
#Author:    Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Jul 31 2008	Amer Khan 	Originally created                           #
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
#        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();

$day_cnt = $ARGV[0];

#print "Running For: $day_cnt"."\n";

$proderver = "CPDB2";

while ($day_cnt ne 0){
###Executing url for parcel batch###
$process_output = `/opt/sybase/cron_scripts/urgent_svp_proc_parcelwork.pl $day_cnt`;

print "$process_output \n";

$day_cnt = $day_cnt - 1;
#print $day_cnt."\n";
}

