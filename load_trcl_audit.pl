#!/usr/bin/perl 

###################################################################################
#Script:   This script converts cmf data from flat files into CPDATA2 cmf_data db #
#          Once the ETL process completes, dump is taken which gets loaded to     #
#          CPDB2, from where it gets loaded to IQ                                 #
#                                                                                 #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#02/03/04       Amer Khan       Originally created                                #
#11/18/04       Amer Khan       Modified to unzip file that is now received       #
#                               directly from OPS3                                #
#10/12/07       Ahsan Ahmed     Modified                                          #
#                                                                                 #
###################################################################################
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

require "/opt/sybase/cron_scripts/accents";

#**********************************************************************************************
print "****Starting trcl_audit bcp*****\n";

open (BCPFILE,">/tmp/trcl_audit.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/TRACE_AUDIT.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
$_ =~ s/^\d\d\d,//;
$_ =~ s/\0/ /g; #Control characters to be taken out
$_ =~ s/\r$//;
$_ =~ s/\n$//;
$_ =~ s/\r/ /g;
$_ =~ s/\n/ /g;
$_ = $_."\n";

####################################################

print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table trcl_audit
go
exit
EOF
bcp cmf_data..trcl_audit in /tmp/trcl_audit.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/trace_audit.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating trcl_audit\n\n$sqlError\n\n";

