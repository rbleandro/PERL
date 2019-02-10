#!/usr/bin/perl

###################################################################################
#Script:   This script keeps track of the database growth and percent increase in #
#          db size from the last reading taken                                    #
#                                                                                 #
#Note:     This script can be used with any database, but you have to have a table#
#          called db_growth_record in the database where it is being executed     #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#02/03/04       Amer Khan       Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 0){
   print "Usage: db_growth.pl CPDATA1 cpscan \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

require "/opt/sybase/cron_scripts/set_sybase_env.pl";

#Store inputs
$server = $ARGV[0];

print "***Initiating BCP FROM ASE for cost_analysis At:".localtime()."***\n";
$bcpError = `bcp cmf_data..cost_analysis_raw out /opt/sybase/bcp_data/cmf_data/cost_analysis_raw.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;

if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From cost_analysis...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: Gary_DaPonte@ainsworth.com
Subject: BCP ERROR: cost_analysis

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for cost_analysis At:".localtime()."***\n";
open(STDERR,"> /tmp/cost_analysis.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_cost_analysis_raw.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/cost_analysis.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/cost_analysis.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlError ){
      print "Messages From cost_analysis...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: Gary_DaPonte@ainsworth.com
Subject: ERROR: cost_analysis

$dbsqlError
EOF
`;
}else{
`/usr/sbin/sendmail -t -i <<EOF
To: frank_orourke\@canpar.com,randy_ogilvie\@canpar.com
Subject: Load of cost_analysis in CPIQ is complete

Thanks
Amer
EOF
`;

}
