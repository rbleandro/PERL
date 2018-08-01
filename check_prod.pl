#!/usr/bin/perl -w

###################################################################################
#Script:   This script determines whether this is a prod server or not and dies if#
#          the server is standby server                				  #
#Author:   Amer Khan								  #
#Date:	   Jan 19 2007								  #
###################################################################################

open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\nScript halted by check_prod.pl\n\n"
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

