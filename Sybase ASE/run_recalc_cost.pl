#!/usr/bin/perl

###################################################################################
#Script:   This script runs recalc_cost. All the sql and logic is built in.       #
#                                         					  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#11/12/04	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 0){
   print "Usage: run_recalc_cost.pl CPDATA1\n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$server = $ARGV[0];

#if (1==2){ #dont run
print "***************Start Recalc Process NOW**************".localtime()."\n";

print "Truncate and Drop existing temp tables for a new recalc\n";
`isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/drop_cost_calc_temp_tables.sql`;

#Clear tempdb tran
`isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF
dump tran tempdb with truncate_only
go
exit
EOF
`;

print "Now running sql 1-5...".localtime()."\n";
$sqlError = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql1 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql2 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql3 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql4 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql5 &
`;

#Clear tempdb tran
`isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF
dump tran tempdb with truncate_only
go
exit
EOF
`;

print "Now running sql 6,8...".localtime()."\n";
$sqlError1 = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql6 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql8 &
`;

#Clear tempdb tran
`isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF
dump tran tempdb with truncate_only
go
exit
EOF
`;

print "Now running sql 7...".localtime()."\n";
$sqlError6 = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql7 &
`;


#Clear tempdb tran
`isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF
dump tran tempdb with truncate_only
go
exit
EOF
`;

print "Now running sql 9-11...".localtime()."\n";
$sqlError2 = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql9 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql10 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql11 &
`;

#Clear tempdb tran
`isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF
dump tran tempdb with truncate_only
go
exit
EOF
`;


print "Now running sql 12-14...".localtime()."\n";
$sqlError3 = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql12 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql13 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql14 &
`;

#Clear tempdb tran
`isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF
dump tran tempdb with truncate_only
go
exit
EOF
`;


print "Now running sql 15-17...".localtime()."\n";
$sqlError4 = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql15 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql16 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql17 &
`;

#Clear tempdb tran
`isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF
dump tran tempdb with truncate_only
go
exit
EOF
`;


print "Now running sql 18-19...".localtime()."\n";
$sqlError5 = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql18 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql19 &
`;   

#Clear tempdb tran
`isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF
dump tran tempdb with truncate_only
go
exit
EOF
`;


print $sqlError;
print $sqlError1;
print $sqlError2;
print $sqlError3;
print $sqlError4;
print $sqlError5;
print $sqlError6;

if ($sqlError =~ /Msg/ || $sqlError ne ''){
      print "Messages From recalc_cost Process...\n";
      print "$sqlError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: recalc_cost Status

Following status was received after recalc_cost on \`date\`
$sqlError
$sqlError1
$sqlError2
$sqlError3
$sqlError4
$sqlError5
$sqlError6
EOF
`;
   }#end of if messages received

print "Ending load of temp tables...".localtime()."\n";

#print "Starting bcp out of data through calc_cost_vw\n";

#`bcp cmf_data..calc_cost_vw out /tmp/calc_cost.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n" > /tmp/calc_cost.out`;

$sqlError = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
use cmf_data
go
truncate table cmf_data..calc_cost
go
drop table cmf_data..calc_cost
go
exit
EOF
`;

print "$sqlError\n";

#$split_count = int((`wc -l /tmp/calc_cost.dat`/6)+1);
#print "Split count is... $split_count\n";

#print "Starting split of dat file into 6 files...".localtime()."\n";
#`cd /tmp
#split -l $split_count /tmp/calc_cost.dat cost`;


#print "Starting bcp into calc_cost...".localtime()."\n";
#`bcp cmf_data..calc_cost in /tmp/calc_cost.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -b30000 -r"\n" > /tmp/calc_cost.out`;


#} #eof dont run

$sqlError = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/create_calc_cost_table.sql`;

print "Error Running Select into: $sqlError \n";

print "Add the index back to the calc_cost table...".localtime()."\n";

`isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
use cmf_data
go
grant all on calc_cost to public
go
CREATE UNIQUE NONCLUSTERED INDEX record_id_un_nc
ON dbo.calc_cost(record_id)
go
exit
EOF
`;

#Clear tempdb tran
`isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF
dump tran tempdb with truncate_only
go
dump tran cmf_data with truncate_only
go
exit
EOF
`;


#The Following line marks the end in the log file, leave at the bottom of this file
print "************************End of Recalc Process at ".localtime()." ******************************\n\n";
