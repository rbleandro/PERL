#!/usr/bin/perl

#Script:   	This script monitor failed cron jobs.
#
#Author:   		Rafael Leandro
#Date			Name				Description
#---------------------------------------------------------------------------------
#Aug 13 2019	Rafael Leandro  	Created

use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use Sys::Hostname;
my $prodserver = hostname();

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $finTime = localtime();

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail
) or die "Usage: $0 --skipcheckprod 0 --to rleandro\n";


#Usage Restrictions
my $hour=sprintf('%02d',((localtime())[2]));
$hour = int($hour);

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

my $grep="";
$grep = `grep -iRl "warning" /opt/sap/cron_scripts/cron_logs ; grep -iRl "unable" /opt/sap/cron_scripts/cron_logs ; grep -iRl "compilation" /opt/sap/cron_scripts/cron_logs ; grep -iRl "No such file" /opt/sap/cron_scripts/cron_logs ; grep -iRl "not found" /opt/sap/cron_scripts/cron_logs ; grep -iRl "denied" /opt/sap/cron_scripts/cron_logs; grep -iRl "Bad IDN" /opt/sap/cron_scripts/cron_logs;grep -iRl "Error sending message" /opt/sap/cron_scripts/cron_logs;`;

if ($grep ne "")
{
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Failed jobs alert!!!

Below is a list of current failing jobs. Check the jobs' logs to see what needs to be done.

$grep

Script name: $0

EOF
`;
}
else
{
print "No failed jobs found.\n";
}
