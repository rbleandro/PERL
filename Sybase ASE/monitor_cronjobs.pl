#!/usr/bin/perl -w

#Script:   This script monitors sybase server  cronjobs that are left            
#          commented for some reason, which should be uncommented. An email will
#          also be sent to inform us if any job is  not running.

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use lib ('/opt/sap/cron_scripts/lib');
use Validation qw( send_alert checkProcessByName showDefaultHelp isProd );

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
my @line="";
my $i=0;

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

#Saving argument
my $crontab = $ARGV[0];
my $createcrontab =`crontab -l > /tmp/crontab.log`;
if($createcrontab){
   print "crontab log created ".$createcrontab."\n";
}
# Open the crontab.log file

my $file = "/tmp/$crontab.log";		
open(INFO, $file);
#Scanning the crontab.log...
while (<INFO>) {
if (substr($_,0,2) ge '#0' and substr($_,0,2) le '#9')
{
$line[$i] = $_;
$i += 1;
}
}
close(INFO);

if( $i > 0)
{
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Comments found on $prodserver cronjob

Job(s) Commented out on CPDB2 cronjob.

@line
EOF
`;
}

`rm /tmp/$crontab.log`;

$currTime = localtime();
print "Process FinTime: $currTime\n";
