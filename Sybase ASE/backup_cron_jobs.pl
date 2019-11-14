#!/usr/bin/perl -w

#Script:   This script dumps various databases to the secondary servers
#
#Author:		Rafael Leandro
#Revision:
#Date           Name            Description
#----------------------------------------------------------------------------
#Aug 14 2019	Rafael Leandro		Created

#Usage Restrictions
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use Sys::Hostname;

my $prodserver = hostname();
my $drserver = 'CPDB4';
my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $finTime = localtime();
my $stbyserver="";

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail
) or die "Usage: $0 --skipcheckprod 0 --to rleandro\n";

if ($skipcheckprod==0){
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod") or die "Can't open < /opt/sap/cron_scripts/passwords/check_prod : $!";

my @prodline="";
while (<PROD>){
	@prodline = split(/\t/, $_);
	$prodline[1] =~ s/\n//g;
}

if ($prodline[1] eq "0" ){
	print "standby server \n";
	die "This is a stand by server\n"
}
}

if ($prodserver eq 'CPDB2'){ $stbyserver = 'CPDB1'; } else { $stbyserver = 'CPDB2'; }

print "Prod: $prodserver....Stby: $stbyserver \n";

#Set starting variables
my $currTime = localtime();
my $startHour=sprintf('%02d',((localtime())[2]));
my $startMin=sprintf('%02d',((localtime())[1]));

my $my_pid = getppid();
my $isProcessRunning =`ps -ef|grep sybase|grep backup_cron_jobs.pl|grep -v grep|grep -v $my_pid|grep -v "vim backup_cron_jobs.pl"|grep -v "less backup_cron_jobs.pl"`;

print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

my $cronbkp=system("/usr/bin/crontab -l > /opt/sap/cron_scripts/cronjobs.bk");
my $stbycopy=system("scp -p /opt/sap/cron_scripts/cronjobs.bk sybase\@$stbyserver:/opt/sap/cron_scripts");
my $drcopy=system("scp -p /opt/sap/cron_scripts/cronjobs.bk sybase\@$drserver:/opt/sap/cron_scripts");

if ($cronbkp !=0){
print $cronbkp."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases at $finTime during generate backup stage

$cronbkp
EOF
`;
die;
}

if ($stbycopy !=0){
print $stbycopy."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases at $finTime during copy to stdby stage

$stbycopy
EOF
`;
die;
}

if ($drcopy !=0){
print $drcopy."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases at $finTime during copy to dr stage

$drcopy
EOF
`;
die;
}

print "Spitting cron entries here as well as secondary backup";
my $cron=`/usr/bin/crontab -l`;

print $cron;

$finTime = localtime();
print "Time Finished: $finTime\n";
