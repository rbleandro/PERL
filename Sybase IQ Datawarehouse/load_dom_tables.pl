#!/usr/bin/perl -w

###################################################################################
#Script:   This script keeps track of the database growth and percent increase in #
#          db size from the last reading taken                                    #
#                                                                                 #
#Note:     This script can be used with any database, but you have to have a table#
#          called db_growth_record in the database where it is being executed     #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#02/03/04	Amer Khan	Originally created                                #
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

print "\n###Running cmf_data load to cpiq on Host:".`hostname`."###\n";
if (1==2){ #start of dont
#*************************Initiating Inserts of new rows into cmf_data tables*************************#

print "***Initiating BCP FROM ASE for APDoc At:".localtime()."***\n";
$bcpError = `bcp cmf_data..APDoc out /opt/sybase/bcp_data/cmf_data/APDoc_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From APDoc...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: APDoc

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for APDoc At:".localtime()."***\n";
open(STDERR,"> /tmp/APDoc.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_APDoc.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/APDoc.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/APDoc.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlError ){
      print "Messages From APDoc...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: APDoc

$dbsqlError
EOF
`;
}else{
`/usr/sbin/sendmail -t -i <<EOF
To: dominic_shou\@canpar.com
Subject: CPIQ: APDoc

Table is now updated with the latest data.
Thanks,
Amer
EOF
`;
}
#}#eof dont run


print "***Initiating BCP FROM ASE for Parts At:".localtime()."***\n";
$bcpError = `bcp cmf_data..Parts out /opt/sybase/bcp_data/cmf_data/Parts_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From Parts...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: Parts

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for Parts At:".localtime()."***\n";
open(STDERR,"> /tmp/Parts.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_Parts.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/Parts.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/Parts.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlError ){
      print "Messages From Parts...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: Parts

$dbsqlError
EOF
`;
}else{
`/usr/sbin/sendmail -t -i <<EOF
To: dominic_shou\@canpar.com
Subject: CPIQ: Parts

Table is now updated with the latest data.
Thanks,
Amer
EOF
`;
}



print "***Initiating BCP FROM ASE for Labor At:".localtime()."***\n";
$bcpError = `bcp cmf_data..Labor out /opt/sybase/bcp_data/cmf_data/Labor_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From Labor...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: Labor

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for Labor At:".localtime()."***\n";
open(STDERR,"> /tmp/Labor.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_Labor.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/Labor.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/Labor.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlError ){
      print "Messages From Labor...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: Labor

$dbsqlError
EOF
`;
}else{
`/usr/sbin/sendmail -t -i <<EOF
To: dominic_shou\@canpar.com
Subject: CPIQ: Labor

Table is now updated with the latest data.
Thanks,
Amer
EOF
`;
}

#} #eof dont
print "***Initiating BCP FROM ASE for LaborSysKMCost At:".localtime()."***\n";
$bcpError = `bcp cmf_data..LaborSysKMCost out /opt/sybase/bcp_data/cmf_data/LaborSysKMCost_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From LaborSysKMCost...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: LaborSysKMCost

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for LaborSysKMCost At:".localtime()."***\n";
open(STDERR,"> /tmp/LaborSysKMCost.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_LaborSysKMCost.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/LaborSysKMCost.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/LaborSysKMCost.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlError ){
      print "Messages From LaborSysKMCost...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: LaborSysKMCost

$dbsqlError
EOF
`;
}else{
`/usr/sbin/sendmail -t -i <<EOF
To: dominic_shou\@canpar.com
Subject: CPIQ: LaborSysKMCost

Table is now updated with the latest data.
Thanks,
Amer
EOF
`;
}


#}#eof dont run
print "***Initiating BCP FROM ASE for PartsSysKMCost At:".localtime()."***\n";
$bcpError = `bcp cmf_data..PartsSysKMCost out /opt/sybase/bcp_data/cmf_data/PartsSysKMCost_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From PartsSysKMCost...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: PartsSysKMCost

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for PartsSysKMCost At:".localtime()."***\n";
open(STDERR,"> /tmp/PartsSysKMCost.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_PartsSysKMCost.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/PartsSysKMCost.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/PartsSysKMCost.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlError ){
      print "Messages From PartsSysKMCost...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: PartsSysKMCost

$dbsqlError
EOF
`;
}else{
`/usr/sbin/sendmail -t -i <<EOF
To: dominic_shou\@canpar.com
Subject: CPIQ: PartsSysKMCost

Table is now updated with the latest data.
Thanks,
Amer
EOF
`;
}
#} #eof dont run
print "***Initiating BCP FROM ASE for LaborPartsSysKMcost At:".localtime()."***\n";
$bcpError = `bcp cmf_data..LaborPartsSysKMcost out /opt/sybase/bcp_data/cmf_data/LaborPartsSysKMcost_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From LaborPartsSysKMcost...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: LaborPartsSysKMcost

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for LaborPartsSysKMcost At:".localtime()."***\n";
open(STDERR,"> /tmp/LaborPartsSysKMcost.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_LaborPartsSysKMcost.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/LaborPartsSysKMcost.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/LaborPartsSysKMcost.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlError ){
      print "Messages From LaborPartsSysKMcost...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: LaborPartsSysKMcost

$dbsqlError
EOF
`;
}else{
`/usr/sbin/sendmail -t -i <<EOF
To: dominic_shou\@canpar.com
Subject: CPIQ: LaborPartsSysKMcost

Table is now updated with the latest data.
Thanks,
Amer
EOF
`;
}

} #eof dont run
print "***Initiating BCP FROM ASE for LaborParts At:".localtime()."***\n";
$bcpError = `bcp cmf_data..LaborParts out /opt/sybase/bcp_data/cmf_data/LaborParts_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From LaborParts...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: LaborParts

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for LaborParts At:".localtime()."***\n";
open(STDERR,"> /tmp/LaborParts.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_LaborParts.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/LaborParts.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/LaborParts.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlError ){
      print "Messages From LaborParts...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: LaborParts

$dbsqlError
EOF
`;
}else{
`/usr/sbin/sendmail -t -i <<EOF
To: dominic_shou\@canpar.com
Subject: CPIQ: LaborParts

Table is now updated with the latest data.
Thanks,
Amer
EOF
`;
}

