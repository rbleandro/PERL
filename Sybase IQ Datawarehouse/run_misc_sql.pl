#!/usr/bin/perl

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
$database = $ARGV[1];


print "\n###Running rev_hist load to cpiq on Host:".`hostname`."###\n";

print "***Initiating BCP FROM ASE for iq_bcxref_update At:".localtime()."***\n";

print "***Initiating LOAD TO IQ for iq_bcxref_update At:".localtime()."***\n";
$dbsqlError = "me no see ";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlError !~ /affected/){
      print "Messages From iq_bcxref_update...\n";
      print "$dbsqlError\n";
die;
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_bcxref_update

$dbsqlError
EOF
`;
}

die;
print "***Initiating BCP FROM ASE for iq_revhstd_update At:".localtime()."***\n";
$bcpError = `bcp rev_hist_rep..revhstd_upd out /opt/sybase/bcp_data/rev_hist/revhstd_upd.dat -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -SCPDATA2 -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From iq_revhstd_update...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com 
Subject: BCP ERROR: iq_revhstd_update

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for iq_revhstd_update At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_revhstd_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/iq_revhstd_update.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_revhstd_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_revhstd_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From iq_revhstd_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_revhstd_update

$dbsqlError
EOF
`;
}


print "***Initiating BCP FROM ASE for iq_revhstf1_update At:".localtime()."***\n";
$bcpError = `bcp rev_hist_rep..revhstf1_upd out /opt/sybase/bcp_data/rev_hist/revhstf1_upd.dat -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -SCPDATA2 -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From iq_revhstf1_update...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: iq_revhstf1_update

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for iq_revhstf1_update At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_revhstf1_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/iq_revhstf1_update.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_revhstf1_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_revhstf1_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From iq_revhstf1_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_revhstf1_update

$dbsqlError
EOF
`;
}


print "***Initiating BCP FROM ASE for iq_revhstf_update At:".localtime()."***\n";
$bcpError = `bcp rev_hist_rep..revhstf_upd out /opt/sybase/bcp_data/rev_hist/revhstf_upd.dat -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -SCPDATA2 -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From iq_revhstf_update...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: iq_revhstf_update

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for iq_revhstf_update At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_revhstf_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/iq_revhstf_update.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_revhstf_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_revhstf_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From iq_revhstf_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_revhstf_update

$dbsqlError
EOF
`;
}


print "***Initiating BCP FROM ASE for iq_revhsth_update At:".localtime()."***\n";
$bcpError = `bcp rev_hist_rep..revhsth_upd out /opt/sybase/bcp_data/rev_hist/revhsth_upd.dat -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -SCPDATA2 -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From iq_revhsth_update...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: iq_revhsth_update

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for iq_revhsth_update At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_revhsth_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/iq_revhsth_update.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_revhsth_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_revhsth_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From iq_revhsth_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_revhsth_update

$dbsqlError
EOF
`;
}


print "***Initiating BCP FROM ASE for iq_revhstm_update At:".localtime()."***\n";
$bcpError = `bcp rev_hist_rep..revhstm_upd out /opt/sybase/bcp_data/rev_hist/revhstm_upd.dat -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -SCPDATA2 -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From iq_revhstm_update...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: iq_revhstm_update

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for iq_revhstm_update At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_revhstm_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/iq_revhstm_update.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_revhstm_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_revhstm_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From iq_revhstm_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_revhstm_update

$dbsqlError
EOF
`;
}


print "***Initiating BCP FROM ASE for iq_revhstr_update At:".localtime()."***\n";
$bcpError = `bcp rev_hist_rep..revhstr_upd out /opt/sybase/bcp_data/rev_hist/revhstr_upd.dat -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -SCPDATA2 -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From iq_revhstr_update...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: iq_revhstr_update

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for iq_revhstr_update At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_revhstr_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/iq_revhstr_update.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_revhstr_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_revhstr_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From iq_revhstr_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_revhstr_update

$dbsqlError
EOF
`;
}

#*************************End of Updates to rev_hist tables                  *************************#

#*************************Initiating Inserts of new rows into rev_hist tables*************************#

print "***Initiating BCP FROM ASE for iq_bcxref_insert At:".localtime()."***\n";
$bcpError = `bcp rev_hist..bcxref_iq_vw out /opt/sybase/bcp_data/rev_hist/bcxref_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From iq_bcxref_insert...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: iq_bcxref_insert

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for iq_bcxref_insert At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_bcxref_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_bcxref.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_bcxref_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_bcxref_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From iq_bcxref_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_bcxref_insert

$dbsqlError
EOF
`;
}


print "***Initiating BCP FROM ASE for iq_revhstd_insert At:".localtime()."***\n";
$bcpError = `bcp rev_hist..revhstd_iq_vw out /opt/sybase/bcp_data/rev_hist/revhstd_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From iq_revhstd_insert...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: iq_revhstd_insert

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for iq_revhstd_insert At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_revhstd_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_revhstd.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_revhstd_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_revhstd_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From iq_revhstd_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_revhstd_insert

$dbsqlError
EOF
`;
}


print "***Initiating BCP FROM ASE for iq_revhstd1_insert At:".localtime()."***\n";
$bcpError = `bcp rev_hist..revhstd1_iq_vw out /opt/sybase/bcp_data/rev_hist/revhstd1_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From iq_revhstd1_insert...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: iq_revhstd1_insert

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for iq_revhstd1_insert At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_revhstd1_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_revhstd1.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_revhstd1_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_revhstd1_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From iq_revhstd1_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_revhstd1_insert

$dbsqlError
EOF
`;
}


print "***Initiating BCP FROM ASE for iq_revhstf_insert At:".localtime()."***\n";
$bcpError = `bcp rev_hist..revhstf_iq_vw out /opt/sybase/bcp_data/rev_hist/revhstf_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From iq_revhstf_insert...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: iq_revhstf_insert

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for iq_revhstf_insert At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_revhstf_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_revhstf.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_revhstf_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_revhstf_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From iq_revhstf_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_revhstf_insert

$dbsqlError
EOF
`;
}


print "***Initiating BCP FROM ASE for iq_revhstf1_insert At:".localtime()."***\n";
$bcpError = `bcp rev_hist..revhstf1_iq_vw out /opt/sybase/bcp_data/rev_hist/revhstf1_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From iq_revhstf1_insert...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: iq_revhstf1_insert

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for iq_revhstf1_insert At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_revhstf1_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_revhstf1.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_revhstf1_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_revhstf1_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From iq_revhstf1_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_revhstf1_insert

$dbsqlError
EOF
`;
}


print "***Initiating BCP FROM ASE for iq_revhsth_insert At:".localtime()."***\n";
$bcpError = `bcp rev_hist..revhsth_iq_vw out /opt/sybase/bcp_data/rev_hist/revhsth_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From iq_revhsth_insert...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: iq_revhsth_insert

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for iq_revhsth_insert At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_revhsth_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_revhsth.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_revhsth_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_revhsth_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From iq_revhsth_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_revhsth_insert

$dbsqlError
EOF
`;
}


print "***Initiating BCP FROM ASE for iq_revhstm_insert At:".localtime()."***\n";
$bcpError = `bcp rev_hist..revhstm_iq_vw out /opt/sybase/bcp_data/rev_hist/revhstm_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From iq_revhstm_insert...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: iq_revhstm_insert

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for iq_revhstm_insert At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_revhstm_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_revhstm.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_revhstm_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_revhstm_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From iq_revhstm_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_revhstm_insert

$dbsqlError
EOF
`;
}


print "***Initiating BCP FROM ASE for iq_revhstr_insert At:".localtime()."***\n";
$bcpError = `bcp rev_hist..revhstr_iq_vw out /opt/sybase/bcp_data/rev_hist/revhstr_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From iq_revhstr_insert...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: iq_revhstr_insert

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for iq_revhstr_insert At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_revhstr_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_revhstr.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_revhstr_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_revhstr_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From iq_revhstr_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_revhstr_insert

$dbsqlError
EOF
`;
}


