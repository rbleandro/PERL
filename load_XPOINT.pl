#!/usr/bin/perl 

###################################################################################
#Script:   This script converts XPOINT data from flat files into CPDATA2          #
#                                                                                 #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#08/20/04	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 1){
   #print "Usage: db_growth.pl CPDATA1 cpscan \n";
#   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";
require "/opt/sybase/cron_scripts/accents";


#**********************************************************************************************
print "****Starting XPOINT bcp*****\n";

open (BCPFILE,">/tmp/XPOINT.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/bcp_data/eameer_test/XPOINT.TXT") || print "cannot open XPOINTX.TXT: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d,//;
   $_ =~ s/\0//g; #Control characters to be taken out
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
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDATA2 -w300 <<EOF 2>&1
use eameer_test
go
truncate table XPOINT
go
exit
EOF
bcp eameer_test..XPOINT in /tmp/XPOINT.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDATA2 -f/opt/sybase/bcp_data/eameer_test/XPOINT.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating XPOINT\n\n$sqlError\n\n";
#**********************************************************************************************
