#!/usr/bin/perl -w

#Script:   This script will copy a procedure from the test server to the production server (it will take a backup of the production version first)  
#usage: copy_proc_to_prod.pl DatabaseName ObjectName

#Version history:
#Feb 21 2019	Rafael Bahia	Created										 

$database = $ARGV[0];
$proc = $ARGV[1]; 

my $dba = $ARGV[2];
if (defined $dba) {
    $mail=$dba;
} else {
    $mail='CANPARDatabaseAdministratorsStaffList';
} 

#Usage Restrictions
use Sys::Hostname;
$testserver = 'CPSYBTEST';
$prodserver = 'CPDB1';
#CANPARDatabaseAdministratorsStaffList

$startHour=sprintf('%02d',((localtime())[2]));
$startMin=sprintf('%02d',((localtime())[1]));

`sudo find /home/sybase/db_backups/toProd/ -mindepth 1 -mtime +14 -delete`;

#$ddlgenOp=`. /opt/sap/SYBASE.sh 
#/opt/sap/ASE-16_0/bin/ddlgen -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$testserver:4100 -TP -Ndbo.$proc -D$database -O/home/sybase/db_backups/toProd/$database-$proc.sql`;

$ddlgenOp=`. /opt/sap/SYBASE.sh 
/opt/sap/OCS-16_0/bin/defncopy -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$testserver out /home/sybase/db_backups/toProd/$database-$proc.sql $database dbo.$proc` ;

if ($ddlgenOp =~ /Error/ || $ddlgenOp =~ /Msg/ || $ddlgenOp =~ /ERROR/){
print $ddlgenOp."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - copy_proc_to_prod at $finTime - generate TEST script

$ddlgenOp

If you need to tweak this script, it is located at /opt/sap/cron_scripts/copy_proc_to_prod.pl
EOF
`;
die;
}

print "Test version exported successfully. Proceeding...\n";

#$ddlgenOp=`. /opt/sap/SYBASE.sh 
#/opt/sap/ASE-16_0/bin/ddlgen -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver:4100 -TP -Ndbo.$proc -D$database -O/home/sybase/db_backups/toProd/backup-$database-$proc-$startHour\_$startMin.sql`;

$ddlgenOp=`. /opt/sap/SYBASE.sh 
/opt/sap/OCS-16_0/bin/defncopy -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver out /home/sybase/db_backups/toProd/backup-$database-$proc-$startHour\_$startMin.sql $database dbo.$proc` ;


if ($ddlgenOp =~ /Error/ || $ddlgenOp =~ /Msg/ || $ddlgenOp =~ /ERROR/){
print $ddlgenOp."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - copy_proc_to_prod at $finTime - generate prod backup script

$ddlgenOp

If you need to tweak this script, it is located at /opt/sap/cron_scripts/copy_proc_to_prod.pl
EOF
`;
die;
}

print "Production version backed up successfully. Proceeding...\n";

#$sqlError = `. /opt/sap/SYBASE.sh
#isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$testserver -D$database -i/home/sybase/db_backups/toProd/$database-$proc.sql`;

$sqlError=`. /opt/sap/SYBASE.sh 
/opt/sap/OCS-16_0/bin/defncopy -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$testserver in /home/sybase/db_backups/toProd/$database-$proc.sql $database` ;

if ($sqlError =~ /Msg/ || $sqlError =~ /Error/ || $ddlgenOp =~ /ERROR/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - copy_proc_to_prod at $finTime - test script deploy 

$sqlError

If you need to tweak this script, it is located at /opt/sap/cron_scripts/copy_proc_to_prod.pl
EOF
`;
die;
}

print "Script tested successfully. Proceeding...\n";

#$sqlError = `. /opt/sap/SYBASE.sh
#isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -D$database -i/home/sybase/db_backups/toProd/$database-$proc.sql`;

$sqlError=`. /opt/sap/SYBASE.sh 
/opt/sap/OCS-16_0/bin/defncopy -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver in /home/sybase/db_backups/toProd/$database-$proc.sql $database` ;


if ($sqlError =~ /Msg/ || $sqlError =~ /Error/ || $ddlgenOp =~ /ERROR/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - copy_proc_to_prod at $finTime - apply script to prod

$sqlError

If you need to tweak this script, it is located at /opt/sap/cron_scripts/copy_proc_to_prod.pl
EOF
`;
die;
}

print "Procedure $proc updated successfully on $prodserver.$database. Now exiting.\n";

