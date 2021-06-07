#!/usr/bin/perl -w

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

use lib ('/opt/sap/cron_scripts/lib'); use Validation qw( send_alert checkProcessByName showDefaultHelp isProd );

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $noalert=0;
my $prodserver = hostname();
my $finTime = localtime();
my $checkProcessRunning=1;
my $my_pid="";
my $currTime="";
my $help=0;
my $sqlError="";
my $database = $ARGV[0];
my $drserver = 'CPDB4';

my $dba = $ARGV[1];
if (defined $dba) {
    $mail=$dba;
} else {
    $mail='CANPARDatabaseAdministratorsStaffList';
}

my $resumerep = $ARGV[2];
if (defined $resumerep) {
    $resumerep=$resumerep;
} else {
    $resumerep=0;
} 

GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'noalert' => \$noalert,
	'help|h' => \$help
) or die showDefaultHelp(1,$0);

showDefaultHelp($help,$0);
checkProcessByName($checkProcessRunning,$0);
isProd($skipcheckprod);

if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}

$currTime = localtime();
print "StartTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver <<EOF 2>&1
use master
go
dump database $database to "/opt/sap/db_backups/$database.dmp" compression=100
go
exit
EOF
`;
if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases_to_dr at $finTime

$sqlError
EOF
`;
die;
}

print "Now copying the dump file to $drserver\n";
my $scpError;
$scpError=`scp -p /opt/sap/db_backups/$database.dmp sybase\@$drserver:/opt/sap/db_backups`;
print "$scpError\n";

$scpError  = $? >> 8;
if ($scpError != 0) {
print "$scpError\n";
$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases_to_test (scp phase) at $finTime

$scpError
EOF
`;
die;
}

print "Now firing the load script at $drserver\n";
my $load_msgs;
$load_msgs = `ssh $drserver /opt/sap/cron_scripts/load_databases_to_dr.pl $database $mail $resumerep`;

print "$load_msgs \n";

$finTime = localtime();
print "Time Finished: $finTime\n";
