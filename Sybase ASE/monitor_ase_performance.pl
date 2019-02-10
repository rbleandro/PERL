#!/usr/bin/perl

###################################################################################
#Script:   This script runs sp_sysmon in the production server and collects info  #
#          for historical records of server usage and performance purposes        #
#Author:   Amer Khan                                                              #
#Date:     Jan 19 2007                                                            #
###################################################################################

#require "/opt/sap/cron_scripts/check_prod.pl";

$report_date = `echo "sysmon_\`date '+%d_%H_%M'\`"`;

$sysmonError = `. /opt/sap/SYBASE.sh
isql -Usa -Ps9b2s3 -SCPSYBTEST -o/opt/sap/cron_scripts/cron_logs/ase_perf_logs/sysmon_\`date "+%d_%H_%M"\` <<EOF 2>&1
sp_sysmon "00:10:00"
go
exit
EOF
`;
print "Any messages from server: $sysmonError\n\n";

if($sysmonError =~ /no|not/ || $sysmonError =~ /Error/i){
   print "Errors may have occurred during sysmon report execution...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: rleandro\@canpar.com
Subject: ERROR - SYSMON REPORT EXECUTION FOR CPSYBTEST

Following status was received after sysmon report procedure execution
$sysmonError
EOF
`;
}else{
   print "A report has been saved in the /opt/sap/cron_scripts/cron_logs/ase_perf_logs/$report_date\n\n";
}
