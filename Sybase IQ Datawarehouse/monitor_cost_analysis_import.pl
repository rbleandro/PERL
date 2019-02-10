#!/usr/bin/perl 

###################################################################################
#Script:   This script keeps track of auditing in cpscan, if new audit records are#
#          added to the sysaudits tables, it sends a page                         #
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
   print "Usage: monitor_auditing.pl CPDATA1 sybsecurity \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

require "/opt/sybase/cron_scripts/set_sybase_env.pl";

if (-e "/tmp/import_done") { 
@tmp_filenames = split("\n",`cat /tmp/import_done`);
#`rm /tmp/import_done`;
   foreach (@tmp_filenames){
   print "$_\n";
      $run_error = `/opt/sybase/cron_scripts/import_cost_analysis.pl CPDATA1 $_`;
   }

print "$run_error\n";
print "Signal Sent On...".localtime()."\n";
}
