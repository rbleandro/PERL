#!/usr/bin/perl -w

#Script:   	Script to load mpr_databases at the secondary servers
#Author:	Rafael Leandro
#Date           Name            Description
#Jun 06 2018	Rafael Leandro	Created
#Aug 02 2019	Rafael Leandro	Changed the backup folder for CPDB2 to /opt/sap/db_backups after remounting it on Linux
#May 17 2020	Rafael Leandro	Added parameter to mail recipient

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $prodserver = "";
my $finTime = localtime();
my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $my_pid = getppid();

GetOptions(
    'to|r=s' => \$mail,
	'server|s=s' => \$prodserver
) or die "Usage: $0 --server|s <server name> --to|r <rleandro>\n";

if ($prodserver eq "") {
	die "Server parameter is mandatory. Usage: $0 --server|s <server name> --to|r <rleandro>\n";
}

print "Server Being Loaded: $prodserver\n";
my $isProcessRunning =`ps -ef|grep sybase|grep load_databases_mpr.pl|grep -v grep|grep -v $my_pid|grep -v "vim load_databases_mpr.pl"|grep -v "less load_databases_mpr.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";
}else{
print "No Previous process is running, continuing\n";
}

print "$finTime\n";

my $sqlError = `. /opt/sap/SYBASE.sh
/krb5/bin/64/kinit -k sybase\@CANPAR.COM
isql_r -V -S$prodserver <<EOF 2>&1
use master
go
load database mpr_data from "/opt/sap/db_backups/mpr_data.dmp"
go
online database mpr_data
go
load database mpr_data_lm from "/opt/sap/db_backups/mpr_data_lm.dmp"
go
online database mpr_data_lm
go
exit
EOF
`;

if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - load_databases_mpr at $finTime

$sqlError
EOF
`;
die;
}else{
$finTime = localtime();
print "Time Finished: $finTime\n";
}
