#!/usr/bin/perl -w

#Script:   		This script backs up the crontab entries to a file and sends it to the secondary servers
#Aug 14 2019	Rafael Leandro		Created
#Sep 01 2020	Rafael Leandro		Corrected alert message
#Oct 11 2020	Rafael Leandro		Now it will also copy perl scripts to the secondary servers

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
my $stbyserver="";

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

if ($prodserver eq 'CPDB2'){ $stbyserver = 'CPDB1'; } else { $stbyserver = 'CPDB2'; }

$currTime = localtime();
print "StartTime: $currTime\n";

system("/usr/bin/crontab -l > /opt/sap/cron_scripts/cronjobs.bk");

my $cronbkp= $? >> 8;

if ($cronbkp !=0){
print $cronbkp."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - backup_cron_jobs at $finTime during generate backup stage
Content-Type: text/html
MIME-Version: 1.0

$cronbkp
EOF
`;
die;
}

system("scp -p /opt/sap/cron_scripts/*.* sybase\@$stbyserver:/opt/sap/cron_scripts");
my $stbycopy=$? >> 8;

if ($stbycopy !=0){
print $stbycopy."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - backup_cron_jobs at $finTime during copy to stdby stage
Content-Type: text/html
MIME-Version: 1.0

$stbycopy
EOF
`;
die;
}

#uncomment this section when the DR server comes back online
#system("scp -p /opt/sap/cron_scripts/*.* sybase\@$drserver:/opt/sap/cron_scripts");
#my $drcopy=$? >> 8;
#if ($drcopy !=0){
#print $drcopy."\n";
#
#$finTime = localtime();
#
#`/usr/sbin/sendmail -t -i <<EOF
#To: $mail\@canpar.com
#Subject: Errors - backup_cron_jobs at $finTime during copy to dr stage
#
#$drcopy
#EOF
#`;
#die;
#}

print "run cat /opt/sap/cron_scripts/cronjobs.bk to print the backup taken here.\n";
#my $cron=`/usr/bin/crontab -l`;
#print $cron;

$finTime = localtime();
print "Time Finished: $finTime\n";
