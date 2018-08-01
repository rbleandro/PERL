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
###################################################################################

#Usage Restrictions
if ($#ARGV != -1){
   print "Usage: monitor_auditing.pl CPDB1 sybsecurity \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";

if (-e "/tmp/import_done") { 
@tmp_filenames = split("\n",`cat /tmp/import_done`);
`rm /tmp/import_done`;
   foreach (@tmp_filenames){
   print "$_\n";
   $run_error =  `ssh cpiq.canpar.com '/opt/sybase/cron_scripts/import_cost_analysis.pl CPDB2 $_ >> /tmp/import_cost_analysis_CPDB2.log 2>\&1'`;
   }
print "*************\nImporting Now...".localtime()."\n";
print "Any SSH Errors: $run_error\n";
print "Signal Sent On...".localtime()."\n";
}
