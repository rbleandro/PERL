#!/usr/bin/perl

###################################################################################
#Script:   This script monitors ps -ef on specific times for slowness issues      #
#                                                                                 #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#Jun 14 2008	Amer Khan	Originally Created                                #
#                                                                                 #
###################################################################################

open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
use Sys::Hostname;
$prodserver = hostname();

if ($prodserver eq "CPDB2" ) {
    $standbyserver = "CPDB1";
}else{
   $standbyserver = "CPDB2";
}

`ps -ef >> /opt/sybase/cron_scripts/cron_logs/ps_ef.out`;
`echo "*********************************************************" >> /opt/sybase/cron_scripts/cron_logs/ps_ef.out`;
print "\nYour output is being saved in cron_logs/ps_ef.out\n";
