#!/usr/bin/perl -w

#Script:   This script will copy a procedure from the test server to the production server (it will take a backup of the production version first)
#usage: copy_proc_to_prod.pl DatabaseName ObjectName

#Version history:
#Feb 21 2019	Rafael Bahia	Created

#Usage Restrictions
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $finTime = localtime();
my $database="";
my $proc="";

GetOptions(
	'database|d=s' => \$database,
	'proc|p=s' => \$proc,
	'to|r=s' => \$mail
) or die "Usage: $0 --database|d svp_cp --proc|p test_proc --to|r rleandro\n";

my $prodserver = 'CPDB1';
my $testserver = 'CPSYBTEST';
my $startHour=sprintf('%02d',((localtime())[2]));
my $startMin=sprintf('%02d',((localtime())[1]));

if ($proc eq "" or $database eq ""){die "\nDatabase name and procedure name are mandatory.\n\n";}

my $deloldfiles=system("sudo find /opt/sap/db_backups/toProd/ -mindepth 1 -mtime +14 -delete");

if ($deloldfiles != 0){
print "$deloldfiles\n";
$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - copy_proc_to_prod (delete old files phase) at $finTime
Content-Type: text/html
MIME-Version: 1.0

$deloldfiles
EOF
`;
print $finTime . "\n";
die "Email sent";
}

my $ddlgenOp=system(". /opt/sap/SYBASE.sh
/opt/sap/OCS-16_0/bin/defncopy_r -V -S$testserver out /opt/sap/db_backups/toProd/$database-$proc.sql $database dbo.$proc") ;

if ($ddlgenOp =~ /Error|ERROR|not found|Msg/ or $ddlgenOp != 0){
print $ddlgenOp."\n";
$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - copy_proc_to_prod at $finTime - generate TEST script
Content-Type: text/html
MIME-Version: 1.0

$ddlgenOp

If you need to tweak this script, it is located at /opt/sap/cron_scripts/copy_proc_to_prod.pl
EOF
`;
die;
}

print "Test version exported successfully. Proceeding...\n";

my $sqlError="";
$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -n -b<<EOF 2>&1
set nocount on
go
use $database
go
select count(*) from sysobjects where name = '$proc'
go
exit
EOF
`;

if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";
$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - copy_proc_to_prod at $finTime during check object existence phase
Content-Type: text/html
MIME-Version: 1.0

$sqlError
EOF
`;
die;
}

$sqlError =~ s/\t//g;
$sqlError =~ s/\s//g;
#print $sqlError;

if ($sqlError == 1)
{
$ddlgenOp=system(". /opt/sap/SYBASE.sh
/opt/sap/OCS-16_0/bin/defncopy_r -V -S$prodserver out /opt/sap/db_backups/toProd/backup-$database-$proc-$startHour\_$startMin.sql $database dbo.$proc") ;

if ($ddlgenOp =~ /Error|ERROR|not found|Msg/ or $ddlgenOp != 0){
print $ddlgenOp."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - copy_proc_to_prod at $finTime - generate prod backup script
Content-Type: text/html
MIME-Version: 1.0

$ddlgenOp

If you need to tweak this script, it is located at /opt/sap/cron_scripts/copy_proc_to_prod.pl
EOF
`;
die;
}

print "Production version backed up successfully. Proceeding...\n";
}else{
print "Object does not exist in production. Proceeding...\n";
}

$sqlError=`. /opt/sap/SYBASE.sh
/opt/sap/OCS-16_0/bin/defncopy_r -V -S$testserver in /opt/sap/db_backups/toProd/$database-$proc.sql $database` ;

if ($sqlError =~ /Error|ERROR|not found|Msg/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - copy_proc_to_prod at $finTime - test script deploy
Content-Type: text/html
MIME-Version: 1.0

$sqlError

If you need to tweak this script, it is located at /opt/sap/cron_scripts/copy_proc_to_prod.pl
EOF
`;
die;
}

print "Script tested successfully. Proceeding...\n";

$sqlError=`. /opt/sap/SYBASE.sh
/opt/sap/OCS-16_0/bin/defncopy_r -V -S$prodserver in /opt/sap/db_backups/toProd/$database-$proc.sql $database` ;

if ($sqlError =~ /Error|ERROR|not found|Msg/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - copy_proc_to_prod at $finTime - apply script to prod
Content-Type: text/html
MIME-Version: 1.0

$sqlError

If you need to tweak this script, it is located at /opt/sap/cron_scripts/copy_proc_to_prod.pl
EOF
`;
die;
}

print "Procedure $proc updated successfully on $prodserver.$database. Now exiting.\n";

