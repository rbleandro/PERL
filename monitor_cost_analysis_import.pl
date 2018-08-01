#!/usr/bin/perl 

###################################################################################
#Script:   This script will run the Import Cost Analysis                          #
#                                                                                 #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#02/09/05	Amer Khan	Originally created                                #
#                                                                                 #
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
if (-e "/tmp/import_signal") {
print "*************\nSignal Recieved, Executing Proc Now...".localtime()."\n";

@tmp_filenames = split("\n",`cat /tmp/import_signal`);
`rm /tmp/import_signal`;
   foreach (@tmp_filenames){
#   print "$_\n";
   $calling_user = $_;
   $sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -b -n -w200<<EOF 2>&1
use cmf_data
go
execute import_costing_data_signal $calling_user
go
exit
EOF
`;
} # eof loop

print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: Cost Analysis Signal Recieved...\`date\`

$sqlError
EOF
`;

die; #If import signal was there , then don't run import done.
}#eof if

if (-e "/tmp/import_done") { 
@tmp_filenames = split("\n",`cat /tmp/import_done`);
`rm /tmp/import_done`;
   foreach (@tmp_filenames){
   print "$_\n";
   $run_error =  `ssh cpiq.canpar.com '/opt/sybase/cron_scripts/import_cost_analysis.pl $prodserver $_ >> /tmp/import_cost_analysis_CPDB1.log 2>\&1'`;
   }
print "*************\nImporting Now...".localtime()."\n";
print "Any SSH Errors: $run_error\n";
print "Signal Sent On...".localtime()."\n";
}
